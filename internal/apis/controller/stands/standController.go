package stands

import (
	"fmt"
	"net/http"
	"strconv"
    "gorm.io/gorm"
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/requests"
	"example/hello/response"
	"github.com/gin-gonic/gin"
	"errors"
)

func stringToTypeStand(typeStandStr string) (models.StandType, error) {
	switch typeStandStr {
	case "NOURRITURE":
		return models.StandNourriture, nil
	case "BOISSON":
		return models.StandBoisson, nil
	case "ACTIVITES":
		return models.StandActivite, nil
	default:
		return models.StandType(0), fmt.Errorf("type invalide: %s", typeStandStr)
	}
}

// CreateStand godoc
// @Summary Create a new stand
// @Description Create a new stand for a kermesse
// @Tags Stand
// @Accept json
// @Produce json
// @Param stand body models.Stand true "Stand object"
// @Success 201 {object} models.Stand
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands [post]
func CreateStand(c *gin.Context) {
	var req requests.CreateStandRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format: " + err.Error()})
		return
	}

	standType, err := stringToTypeStand(req.Type)
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: err.Error()})
		return
	}

	stand := models.Stand{
		Nom:             req.Nom,
		Type:            standType,
		KermesseID:      req.KermesseID,
		TeneurID:        req.TeneurID,
		PositionX:       req.PositionX,
		PositionY:       req.PositionY,
		JetonsCollectes: req.JetonsCollectes,
		PointsAttribues: req.PointsAttribues,
	}

	if err := initializers.DB.Create(&stand).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create stand: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, response.StandResponse{
		ID:              stand.ID,
		Nom:             stand.Nom,
		Type:            stand.Type.String(),
		KermesseID:      stand.KermesseID,
		TeneurID:        stand.TeneurID,
		PositionX:       stand.PositionX,
		PositionY:       stand.PositionY,
		JetonsCollectes: stand.JetonsCollectes,
		PointsAttribues: stand.PointsAttribues,
	})
}

// GetStand godoc
// @Summary Get a stand
// @Description Get details of a specific stand
// @Tags Stand
// @Produce json
// @Param id path int true "Stand ID"
// @Success 200 {object} models.Stand
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id} [get]
func GetStand(c *gin.Context) {
	id := c.Param("id")
	var stand models.Stand
	if err := initializers.DB.Preload("Stocks").First(&stand, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stock not found"})
		return
	}
	c.JSON(http.StatusOK, stand)
}

// GetStands godoc
// @Summary Get all stands
// @Description Retrieve a list of all stands
// @Tags Stand
// @Produce json
// @Success 200 {array} response.SuccessResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands [get]
func GetAllStands(c *gin.Context) {
    var stands []models.Stand
    if err := initializers.DB.Preload("Stocks").Find(&stands).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Échec de la récupération des stands"})
        return
    }

    c.JSON(http.StatusOK,stands)
}

// UpdateStand godoc
// @Summary Update a stand
// @Description Update details of a specific stand
// @Tags Stand
// @Accept json
// @Produce json
// @Param id path int true "Stand ID"
// @Param stand body models.Stand true "Updated stand object"
// @Success 200 {object} models.Stand
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id} [put]
func UpdateStand(c *gin.Context) {
	id := c.Param("id")
	var stand models.Stand
	if err := initializers.DB.First(&stand, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stand not found"})
		return
	}

	if err := c.ShouldBindJSON(&stand); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	initializers.DB.Save(&stand)
	c.JSON(http.StatusOK, stand)
}

// DeleteStand godoc
// @Summary Delete a stand
// @Description Delete a specific stand
// @Tags Stand
// @Produce json
// @Param id path int true "Stand ID"
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id} [delete]
func DeleteStand(c *gin.Context) {
	id := c.Param("id")
	if err := initializers.DB.Delete(&models.Stand{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to delete stand"})
		return
	}
	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

// ManageStock godoc
// @Summary Manage stock for a stand
// @Description Add or update stock for a specific stand
// @Tags Stand
// @Accept json
// @Produce json
// @Param id path int true "Stand ID"
// @Param stock body models.Stock true "Stock object"
// @Success 201 {object} models.Stock
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id}/stock [post]
func ManageStock(c *gin.Context) {
	standID := c.Param("id")
	var stock models.Stock

	// Bind the JSON input to the stock model
	if err := c.ShouldBindJSON(&stock); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	// Parse the standID from string to uint64
	parsedStandID, err := strconv.ParseUint(standID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid stand ID"})
		return
	}

	// Convert uint64 to uint and assign it to stock.StandID
	stock.StandID = uint(parsedStandID)

	// Create the stock entry in the database
	if err := initializers.DB.Create(&stock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create/update stock for stand"})
		return
	}

	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

// CollectJetons godoc
// @Summary Collect jetons for a stand
// @Description Collect jetons for a specific stand
// @Tags Stand
// @Accept json
// @Produce json
// @Param id path int true "Stand ID"
// @Param jetons body models.Stand true "Jeton collection object"
// @Success 200 {object} models.Stand
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id}/jetons [post]
func CollectJetons(c *gin.Context) {
	standID := c.Param("id")
	var jetonsData struct {
		Montant int `json:"montant"`
	}
	if err := c.ShouldBindJSON(&jetonsData); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	var stand models.Stand
	if err := initializers.DB.First(&stand, standID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stand not found"})
		return
	}

	stand.JetonsCollectes += jetonsData.Montant
	initializers.DB.Save(&stand)

	c.JSON(http.StatusOK, response.JetonCollectesResponse{
		Message:     "Jetons collected successfully",
		TotalJetons: int64(stand.JetonsCollectes),
	})
}

// AttributePoints godoc
// @Summary Attribute points for a stand and a user
// @Description Attribute points for a specific stand (only for activity stands) to a parent or student
// @Tags Stand
// @Accept json
// @Produce json
// @Param points body models.Stand  true "Points attribution object"
// @Success 200 {object} response.PointsAttributionResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/points [post]
func AttributePoints(c *gin.Context) {
    var req struct {
        Points   int    `json:"points" binding:"required"`
        UserID   uint   `json:"userId" binding:"required"`
        UserType string `json:"userType" binding:"required,oneof=parent student"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
        return
    }

    tx := initializers.DB.Begin()
    defer func() {
        if r := recover(); r != nil {
            tx.Rollback()
        }
    }()

    // Mettre à jour les points de l'utilisateur
    var updatedPoints int
    var userName string
    if err := updateUserPoints(tx, req.UserType, req.UserID, req.Points, &updatedPoints, &userName); err != nil {
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    if err := tx.Commit().Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "message": "Points attributed successfully",
        "userId": req.UserID,
        "userName": userName,
        "userType": req.UserType,
        "pointsAdded": req.Points,
        "totalPoints": updatedPoints,
    })
}

func updateUserPoints(tx *gorm.DB, userType string, userID uint, points int, updatedPoints *int, userName *string) error {
    if userType == "parent" {
        var parent models.Parent
        if err := tx.First(&parent, userID).Error; err != nil {
            return errors.New("Parent not found")
        }
        parent.PointsAccumules += points
        *updatedPoints = parent.PointsAccumules
       // *userName = parent.Name
        return tx.Save(&parent).Error
    } else {
        var student models.Eleve
        if err := tx.First(&student, userID).Error; err != nil {
            return errors.New("Student not found")
        }
        student.PointsAccumules += points
        *updatedPoints = student.PointsAccumules
       // *userName = student.Name
        return tx.Save(&student).Error
    }
}