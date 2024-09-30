package tombola

import (
	"example/hello/common"
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/requests"
	"example/hello/response"
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// CreateTombola godoc
// @Summary Create a new tombola
// @Description Create a new tombola for a kermesse
// @Tags Tombola
// @Accept json
// @Produce json
// @Param id path int true "Kermesse ID"
// @Param tombola body models.Tombola true "Tombola data"
// @Success 201 {object} models.Tombola
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id}/tombolas [post]
func CreateTombola(c *gin.Context) {
	var req requests.CreateTombolaRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format: " + err.Error()})
		return
	}

	tombola := models.Tombola{
		Nom:        req.Nom,
		KermesseID: req.KermesseID,
	}

	if err := initializers.DB.Create(&tombola).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create tombola: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, response.StandResponse{
		ID:         tombola.ID,
		Nom:        tombola.Nom,
		KermesseID: tombola.KermesseID,
	})

}

// GetTombola godoc
// @Summary Get tombola details
// @Description Get details of a specific tombola
// @Tags Tombola
// @Produce json
// @Param id path int true "Tombola ID"
// @Success 200 {object} models.Tombola
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id} [get]
func GetTombola(c *gin.Context) {
	id := c.Param("id")
	var tombola models.Tombola
	if err := initializers.DB.Preload("Lots").Preload("Tickets").First(&tombola, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Tombola not found"})
		return
	}
	c.JSON(http.StatusOK, tombola)
}

// generateTicketNumber génère un numéro de ticket unique
func generateTicketNumber() (string, error) {
	// Préfixe pour indiquer que c'est un ticket
	prefix := "T-"

	// Récupère l'horodatage actuel en nanosecondes
	timestamp := strconv.FormatInt(time.Now().UnixNano(), 10)

	// Génère une portion aléatoire (par exemple, un nombre aléatoire de 4 chiffres)
	randomNumber, err := common.GenerateRandomNumber(1000, 9999)
	if err != nil {
		return "", err
	}

	// Retourne le numéro de ticket sous la forme "T-<timestamp>-<randomNumber>"
	return fmt.Sprintf("%s%s-%d", prefix, timestamp, randomNumber), nil
}

// BuyTicket godoc
// @Summary Buy a ticket for tombola
// @Description Buy a ticket for a specific tombola
// @Tags Ticket
// @Accept json
// @Produce json
// @Param id path int true "Tombola ID"
// @Param ticket body models.Ticket true "Ticket purchase data"
// @Success 201 {object} models.Ticket
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/tickets [post]
func BuyTicket(c *gin.Context) {
	tombolaID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid tombola ID"})
		return
	}

	var purchase struct {
		UserID uint `json:"user_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&purchase); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: err.Error()})
		return
	}

	const prixTicket = 2 // Prix fixe du ticket en jetons

	// Vérifier le solde de jetons de l'utilisateur
	var user models.User
	if err := initializers.DB.First(&user, purchase.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "User not found"})
		return
	}

	if user.SoldeJetons < prixTicket {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Insufficient jeton balance"})
		return
	}

	// Générer un numéro de ticket unique
	numero, err := generateTicketNumber()
	if err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to generate ticket number"})
		return
	}

	// Commencer une transaction
	tx := initializers.DB.Begin()

	// Créer le ticket
	tombolaIDUint := uint(tombolaID)
	ticket := models.Ticket{
		TombolaID:    &tombolaIDUint,
		UserID:       purchase.UserID,
		Numero:       numero,
		EstGagnant:   false,
		PrixEnJetons: prixTicket, // Assigner le prix fixe au ticket
	}

	if err := tx.Create(&ticket).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create ticket"})
		return
	}

	// Mettre à jour le solde de jetons de l'utilisateur
	user.SoldeJetons -= prixTicket
	if err := tx.Save(&user).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to update user balance"})
		return
	}

	// Enregistrer la transaction de jetons
	jetonTransaction := models.JetonTransaction{
		UserID:      user.ID,
		Montant:     prixTicket,
		Type:        "ACHAT",
		Description: fmt.Sprintf("Achat d'un ticket pour la tombola %d", tombolaID),
	}

	if err := tx.Create(&jetonTransaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to record jeton transaction"})
		return
	}

	// Commit de la transaction
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to complete ticket purchase"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":     "Ticket purchased successfully",
		"ticket":      ticket,
		"new_balance": user.SoldeJetons,
	})
}

// PerformDraw godoc
// @Summary Perform tombola draw
// @Description Perform the draw for a tombola and assign winners
// @Tags Tombola
// @Produce json
// @Param id path int true "Tombola ID"
// @Success 200 {object} models.Tombola
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/draw [post]
func PerformDraw(c *gin.Context) {
	id := c.Param("id")
	var tombola models.Tombola
	if err := initializers.DB.Preload("Lots").Preload("Tickets").First(&tombola, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Tombola not found"})
		return
	}

	// Vérifier s'il y a des tickets et des lots
	if len(tombola.Tickets) == 0 {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "No tickets available for the draw"})
		return
	}
	if len(tombola.Lots) == 0 {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "No lots available for the draw"})
		return
	}

	// Effectuer le tirage
	winners, err := performDrawLogic(&tombola)
	if err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: fmt.Sprintf("Failed to perform draw: %v", err)})
		return
	}

	if len(winners) == 0 {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "No winners were selected in the draw"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"winners": winners})
}
func performDrawLogic(tombola *models.Tombola) ([]models.Gagnant, error) {
	var winners []models.Gagnant
	availableTickets := tombola.Tickets
	availableLots := tombola.Lots

	// Mélanger les tickets
	shuffleTickets(availableTickets)

	for _, lot := range availableLots {
		if len(availableTickets) == 0 {
			break // Plus de tickets disponibles
		}

		// Sélectionner le premier ticket (qui est maintenant aléatoire grâce au mélange)
		winningTicket := availableTickets[0]
		availableTickets = availableTickets[1:] // Retirer le ticket gagnant

		winner := models.Gagnant{
			UserID:    winningTicket.UserID,
			TicketID:  winningTicket.ID,
			LotID:     lot.ID,
			TombolaID: tombola.ID,
		}
		winners = append(winners, winner)

		// Marquer le ticket comme gagnant
		winningTicket.EstGagnant = true
		if err := initializers.DB.Save(&winningTicket).Error; err != nil {
			return nil, fmt.Errorf("failed to update winning ticket: %v", err)
		}
	}

	// Sauvegarder les gagnants dans la base de données
	for _, winner := range winners {
		if err := initializers.DB.Create(&winner).Error; err != nil {
			return nil, fmt.Errorf("failed to save winner: %v", err)
		}
	}

	return winners, nil
}

// shuffleTickets mélange la slice de tickets en utilisant l'algorithme de Fisher-Yates
func shuffleTickets(tickets []models.Ticket) {
	rand.Seed(time.Now().UnixNano())
	for i := len(tickets) - 1; i > 0; i-- {
		j := rand.Intn(i + 1)
		tickets[i], tickets[j] = tickets[j], tickets[i]
	}
}
