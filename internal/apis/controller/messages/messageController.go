package messages

import (
	"encoding/json"
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Assurez-vous d'implémenter une vérification d'origine appropriée en production
	},
}

var clients = make(map[uint]*websocket.Conn)

// HandleWebSocket godoc
// @Summary Établir une connexion WebSocket
// @Description Établit une connexion WebSocket pour la messagerie en temps réel
// @Tags Chat
// @Accept  json
// @Produce  json
// @Param user_id path int true "ID de l'utilisateur"
// @Success 101 {string} string "Switching Protocols"
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/ws/{user_id} [get]
func HandleWebSocket(c *gin.Context) {
	log.Println("Tentative de connexion WebSocket")
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Erreur lors de la mise à niveau WebSocket:", err)
		return
	}
	defer conn.Close()

	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		log.Println("Invalid user ID:", err)
		return
	}

	userIDUint := uint(userID)
	clients[userIDUint] = conn

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			delete(clients, userIDUint)
			return
		}

		var msg models.Message
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Println(err)
			continue
		}

		// Sauvegarde du message dans la base de données
		if err := initializers.DB.Create(&msg).Error; err != nil {
			log.Println(err)
			continue
		}

		// Envoyer le message au destinataire s'il est connecté
		if recipient, ok := clients[msg.DestinataireID]; ok {
			recipient.WriteJSON(msg)
		}
	}
}

// SendMessage godoc
// @Summary Send a new message
// @Description Send a new message to another user
// @Tags Chat
// @Accept json
// @Produce json
// @Param message body models.Message true "Message object"
// @Success 201 {object} models.Message
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/messages [post]
func SendMessage(c *gin.Context) {
	var message models.Message
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Format de requête invalide"})
		return
	}

	message.Lu = false

	if err := initializers.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Échec de l'envoi du message"})
		return
	}

	// Envoyer le message en temps réel si le destinataire est connecté
	if recipient, ok := clients[message.DestinataireID]; ok {
		recipient.WriteJSON(message)
	}

	c.JSON(http.StatusCreated, message)
}

// GetUserMessages godoc
// @Summary Get user's messages
// @Description Get all messages for a specific user (sent and received)
// @Tags Chat
// @Produce json
// @Param id path int true "User ID"
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/{id}/messages [get]
func GetUserMessages(c *gin.Context) {
	userID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	var messages []models.Message

	// Récupérer les messages où l'utilisateur est soit l'expéditeur soit le destinataire
	if err := initializers.DB.Where("expediteur_id = ? OR destinataire_id = ?", userID, userID).
		Preload("Expediteur").Preload("Destinataire").Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve messages"})
		return
	}

	// Vérifier si des messages ont été trouvés
	if len(messages) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No messages found for this user"})
		return
	}

	// Renvoie les messages
	c.JSON(http.StatusOK, messages)
}

// GetConversation godoc
// @Summary Get conversation between two users
// @Description Get all messages exchanged between two specific users
// @Tags Chat
// @Produce json
// @Param userId1 path int true "First User ID"
// @Param userId2 path int true "Second User ID"
// @Success 200 {array} models.Message
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/conversations/{userId1}/{userId2} [get]
func GetConversation(c *gin.Context) {
	userID1, _ := strconv.Atoi(c.Param("userId1"))
	userID2, _ := strconv.Atoi(c.Param("userId2"))
	var messages []models.Message
	if err := initializers.DB.Where(
		"(expediteur_id = ? AND destinataire_id = ?) OR (expediteur_id = ? AND destinataire_id = ?)",
		userID1, userID2, userID2, userID1).
		Preload("Expediteur").Preload("Destinataire").
		Order("id ASC").Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrive conversation"})
		return
	}

	if len(messages) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No messages found for these users"})
		return
	}
	c.JSON(http.StatusOK, messages)
}

// MarkMessageAsRead godoc
// @Summary Mark a message as read
// @Description Mark a specific message as read
// @Tags Chat
// @Produce json
// @Param id path int true "Message ID"
// @Success 200 {object} models.Message
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/messages/{id}/read [put]
func MarkMessageAsRead(c *gin.Context) {
	messageID, _ := strconv.Atoi(c.Param("id"))
	var message models.Message
	if err := initializers.DB.First(&message, messageID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Message not found"})
		return
	}

	message.Lu = true
	if err := initializers.DB.Save(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to mark message as read"})
		return
	}

	c.JSON(http.StatusOK, message)
}

// GetUnreadMessages godoc
// @Summary Get unread messages for a user
// @Description Get all unread messages for a specific user
// @Tags Chat
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {array} models.Message
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/{id}/messages/unread [get]
func GetUnreadMessages(c *gin.Context) {
	userID, _ := strconv.Atoi(c.Param("id"))
	var messages []models.Message
	if err := initializers.DB.Where("destinataire_id = ? AND lu = ?", userID, false).
		Preload("Expediteur").Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve unread messages"})
		return
	}

	if len(messages) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No messaages unread"})
		return
	}
	c.JSON(http.StatusOK, messages)
}
