package jetons

import (
	"github.com/stripe/stripe-go"
    "github.com/stripe/stripe-go/paymentintent"
	"example/hello/internal/apis/services"
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/requests"
	"example/hello/response"
	"fmt"
	"net/http"
	"strconv"
	"time"
	"os"
	"github.com/gin-gonic/gin"
)


// CreateJetonTransaction godoc
// @Summary Create a new jeton transaction
// @Description Create a new jeton transaction
// @Tags JetonTransaction
// @Accept json
// @Produce json
// @Param transaction body models.JetonTransaction true "Jeton transaction object"
// @Success 201 {object} models.JetonTransaction
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/jeton-transactions [post]
func CreateJetonTransaction(c *gin.Context) {
	var req requests.CreateJetonsTransactionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format: " + err.Error()})
		return
	}

	req.Date = time.Now()

	jetons_transaction := models.JetonTransaction{
		Description: req.Description,
		Type:        models.TransactionType(req.Type),
		Montant:     int64(req.Montant),
		Date:        req.Date,
		UserID:      req.UserID,
		StandID:     req.StandID,
	}

	if err := initializers.DB.Create(&jetons_transaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create transaction"})
		return
	}

	c.JSON(http.StatusCreated, jetons_transaction)
}

// PayWithJetons godoc
// @Summary Pay for items or activities at a stand with jetons
// @Description Allow users to pay with jetons for food, drinks, or activities at a specific stand
// @Tags JetonTransaction
// @Accept json
// @Produce json
// @Param request body requests.PaymentRequest true "Payment details"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/jeton-transactions/pay-with-jetons [post]
func PayWithJetons(c *gin.Context) {
	var req requests.PaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Récupérer le stand avec son stock
	var stand models.Stand
	if err := initializers.DB.Preload("Stocks").First(&stand, req.StandID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stand not found"})
		return
	}

	// Vérifier si le stand a du stock
	if len(stand.Stocks) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No stock available for this stand"})
		return
	}

	// Pour simplifier, nous utilisons le premier item du stock
	stock := stand.Stocks[0]

	// Calculer le coût total
	totalCost := int64(stock.PrixEnJetons * req.Quantity)

	// Vérifier le solde de l'utilisateur
	user, err := services.GetUserByID(req.UserID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if user.SoldeJetons < totalCost {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient jeton balance"})
		return
	}

	// Début de la transaction
	tx := initializers.DB.Begin()

	// Déduire les jetons du solde de l'utilisateur
	user.SoldeJetons -= totalCost
	if err := tx.Save(&user).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user balance"})
		return
	}

	// Ajouter les jetons collectés au stand
	stand.JetonsCollectes += int(totalCost)
	if err := tx.Save(&stand).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update stand jetons"})
		return
	}

	// Enregistrer la transaction
	transaction := models.JetonTransaction{
		UserID:      req.UserID,
		Montant:     int64(totalCost),
		Type:        "ACHAT",
		Description: fmt.Sprintf("Achat de %d %s au stand %s (ID: %d)", req.Quantity, stock.NomProduit, stand.Nom, stand.ID),
		StandID:     &stand.ID,
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record transaction"})
		return
	}

	// Gérer le stock ou les points selon le type de stand
	switch stand.Type {
    case models.StandNourriture, models.StandBoisson:
        if err := services.UpdateStandStock(tx, stand.ID, -int(req.Quantity)); err != nil {
            tx.Rollback()
            c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to update stock: %v", err)})
            return
        }
    case models.StandActivite:
        if err := services.UpdateStandStock(tx, stand.ID, -int(req.Quantity)); err != nil {
            tx.Rollback()
            c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to update stock: %v", err)})
            return
        }

        totalPoints := 10 * int(req.Quantity)

        // Chercher d'abord dans la table des parents
        var parent models.Parent
        if err := tx.Where("id = ?", req.UserID).First(&parent).Error; err == nil {
            // C'est un parent
            parent.PointsAccumules += totalPoints
            if err := tx.Save(&parent).Error; err != nil {
                tx.Rollback()
                c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update parent points"})
                return
            }
        } else {
            // Si ce n'est pas un parent, chercher dans la table des élèves
            var eleve models.Eleve
            if err := tx.Where("id = ?", req.UserID).First(&eleve).Error; err == nil {
                // C'est un élève
                eleve.PointsAccumules += totalPoints
                if err := tx.Save(&eleve).Error; err != nil {
                    tx.Rollback()
                    c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update student points"})
                    return
                }
            } else {
                // Ni parent ni élève
                tx.Rollback()
                c.JSON(http.StatusBadRequest, gin.H{"error": "User is neither a parent nor a student"})
                return
            }
        }
    }

    // Commit de la transaction
    if err := tx.Commit().Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete payment"})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "message":     "Payment successful",
        "new_balance": user.SoldeJetons,
        "total_cost":  totalCost,
    })
}

// BuyJetons godoc
// @Summary Acheter des jetons avec de l'argent réel
// @Description Permet à un utilisateur d'acheter des jetons en utilisant de l'argent réel
// @Tags JetonTransaction
// @Accept json
// @Produce json
// @Param request body requests.BuyJetonsRequest true "Détails de l'achat de jetons"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/jeton-transaction/buy [post]
func BuyJetons(c *gin.Context) {
	var req struct {
		UserID    uint   `json:"user_id" binding:"required"`
		Amount    int64  `json:"amount" binding:"required,gt=0"`
		TokenAmount int   `json:"token_amount" binding:"required,gt=0"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	 stripe.Key = os.Getenv("STRIPE_KEY")

	 // Créer une intention de paiement Stripe
        params := &stripe.PaymentIntentParams{
            Amount:   stripe.Int64(req.Amount),
            Currency: stripe.String("eur"),

        }

        pi, err := paymentintent.New(params)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création de l'intention de paiement"})
            return
        }

	jetonsToAdd := int(req.TokenAmount)

	tx := initializers.DB.Begin()

	var user models.User
	if err := tx.First(&user, req.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.SoldeJetons += int64(jetonsToAdd)
	if err := tx.Save(&user).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user balance"})
		return
	}

	transaction := models.JetonTransaction{
		UserID:      req.UserID,
		Montant:     req.Amount,
		Type:        "ACHAT",
		Description: fmt.Sprintf("Achat de %d jetons", jetonsToAdd),
		PaiementID:  pi.ClientSecret,
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record transaction"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete jeton purchase"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "Jetons purchased successfully",
		"new_balance": user.SoldeJetons,
		"payment_id":  pi.ClientSecret,
		"client_secret": pi.ClientSecret,
	})
}

// AttributeJetonsToChild godoc
// @Summary Attribuer des jetons à un enfant
// @Description Permet à un parent de transférer des jetons à son enfant
// @Tags JetonTransaction
// @Accept json
// @Produce json
// @Param request body requests.AttributeJetonsRequest true "Détails du transfert de jetons"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/jeton-transaction/transfer [post]
// Fonction pour attribuer des jetons à un enfant
func AttributeJetonsToChild(c *gin.Context) {
	var req struct {
		ParentID uint  `json:"parent_id" binding:"required"`
		ChildID  uint  `json:"child_id" binding:"required"`
		Amount   int64 `json:"amount" binding:"required,gt=0"`
	}

	// 1. Vérification des paramètres de la requête
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 2. Démarrer une transaction
	tx := initializers.DB.Begin()

	// 3. Rechercher le parent dans la table 'user'
	var parent models.User
	if err := tx.First(&parent, req.ParentID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Parent not found"})
		return
	}

	// 4. Rechercher l'enfant dans la table 'enfant' pour vérifier la relation parent-enfant
	var child models.Eleve
	if err := tx.First(&child, req.ChildID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Child not found"})
		return
	}

	// 5. Vérifier la relation parent-enfant
	var parentModel models.Parent
	if err := tx.Where("user_id = ?", req.ParentID).Preload("Enfants").First(&parentModel).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Parent-child relationship not found"})
		return
	}

	childFound := false
	for _, enfant := range parentModel.Enfants {
		if enfant.ID == req.ChildID {
			childFound = true
			break
		}
	}

	if !childFound {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "This child is not associated with the parent"})
		return
	}

	// 6. Rechercher l'enfant dans la table 'user' pour mettre à jour son solde de jetons
	var childUser models.User
	if err := tx.First(&childUser, child.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Child's user account not found"})
		return
	}

	// 7. Vérifier que le parent a suffisamment de jetons
	if parent.SoldeJetons < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient jetons"})
		return
	}

	// 8. Mise à jour des soldes jetons dans la table 'user'
	parent.SoldeJetons -= req.Amount
	childUser.SoldeJetons += req.Amount

	if err := tx.Save(&parent).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update parent balance"})
		return
	}

	if err := tx.Save(&childUser).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update child balance"})
		return
	}

	// 9. Créer une transaction pour enregistrer le transfert de jetons
	transaction := models.JetonTransaction{
		UserID:      req.ParentID,
		Montant:     int64(-req.Amount),
		Type:        "TRANSFERT",
		Description: fmt.Sprintf("Transfert de %d jetons à l'enfant", req.Amount),
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record transaction"})
		return
	}


	// 10. Commit de la transaction
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete jeton transfer"})
		return
	}

	// 11. Réponse de succès
	c.JSON(http.StatusOK, gin.H{
		"message":            "Jetons transferred successfully",
		"parent_new_balance": parent.SoldeJetons,
		"child_new_balance":  childUser.SoldeJetons,
	})
}

// GetUserTransactions godoc
// @Summary Get user's jeton transactions
// @Description Get all jeton transactions for a specific user
// @Tags JetonTransaction
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {array} models.JetonTransaction
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/{id}/jeton-transactions [get]
func GetUserTransactions(c *gin.Context) {
	userID, _ := strconv.Atoi(c.Param("id"))
	var transactions []models.JetonTransaction
	if err := initializers.DB.Where("user_id = ?", userID).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve transactions"})
		return
	}
	if len(transactions) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No transactions found for this users"})
		return
	}

	c.JSON(http.StatusOK, transactions)
}

// GetStandTransactions godoc
// @Summary Get stand's jeton transactions
// @Description Get all jeton transactions for a specific stand
// @Tags JetonTransaction
// @Produce json
// @Param id path int true "Stand ID"
// @Success 200 {array} models.JetonTransaction
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id}/jeton-transactions [get]
func GetStandTransactions(c *gin.Context) {
	standID, _ := strconv.Atoi(c.Param("id"))
	var transactions []models.JetonTransaction
	if err := initializers.DB.Where("stand_id = ?", standID).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve transactions"})
		return
	}

	if len(transactions) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No transactions found for this stand"})
		return
	}
	c.JSON(http.StatusOK, transactions)
}

// GetTransactionSummary godoc
// @Summary Get transaction summary
// @Description Get a summary of all jeton transactions
// @Tags JetonTransaction
// @Produce json
// @Success 200 {object} models.JetonTransaction
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/jeton-transactions/summary [get]
func GetTransactionSummary(c *gin.Context) {
	var summary struct {
		TotalAchats       int
		TotalUtilisations int
		TotalTransferts   int
	}

	if err := initializers.DB.Model(&models.JetonTransaction{}).
		Select("SUM(CASE WHEN type = ? THEN montant ELSE 0 END) as total_achats, "+
			"SUM(CASE WHEN type = ? THEN montant ELSE 0 END) as total_utilisations, "+
			"SUM(CASE WHEN type = ? THEN montant ELSE 0 END) as total_transferts",
			models.TransactionTypeAchat, models.TransactionTypeUtilisation, models.TransactionTypeTransfert).
		Row().Scan(&summary.TotalAchats, &summary.TotalUtilisations, &summary.TotalTransferts); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve transaction summary"})
		return
	}

	c.JSON(http.StatusOK, summary)
}
