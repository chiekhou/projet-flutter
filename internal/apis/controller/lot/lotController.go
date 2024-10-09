package lot

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateLot godoc
// @Summary Create a new lot
// @Description Create a new lot for a kermesse
// @Tags Lot
// @Accept json
// @Produce json
// @Param id path int true "Tombola ID"
// @Param tombola body models.Lot true "Tombola data"
// @Success 201 {object} models.Lot
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/lots [post]
func CreateLot(c *gin.Context) {
	tombolaID, _ := strconv.Atoi(c.Param("id"))
	var lot models.Lot
	if err := c.ShouldBindJSON(&lot); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}
	lot.TombolaID = uint(tombolaID)
	if err := initializers.DB.Create(&lot).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create lot"})
		return
	}
	c.JSON(http.StatusCreated, lot)
}

// GetLots godoc
// @Summary Get all lots
// @Description Retrieve a list of all lots
// @Tags Lot
// @Produce json
// @Param id path int true "Tombola ID"
// @Success 200 {array} response.LotResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/lots [get]
func GetLots(c *gin.Context) {
	tombolaID, _ := strconv.Atoi(c.Param("id"))
	var lots []models.Lot

	// Récupérer les lots pour la tombola donnée
	if err := initializers.DB.Where("tombola_id = ?", tombolaID).Find(&lots).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve lots"})
		return
	}

	// Vérifier si la liste de lots est vide
	if len(lots) == 0 {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No lots found for this tombola"})
		return
	}

	// Renvoyer les lots s'ils existent
	c.JSON(http.StatusOK, lots)
}

// UpdateLot godoc
// @Summary Update a lot
// @Description Update details of a specific lot
// @Tags Lot
// @Accept json
// @Produce json
// @Param id path int true "Lot ID"
// @Param kermesse body models.Lot true "Updated lot data"
// @Success 200 {object} response.LotResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/lots/{id} [put]
func UpdateLot(c *gin.Context) {
	id := c.Param("id")
	var lot models.Lot
	if err := initializers.DB.First(&lot, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Lot not found"})
		return
	}
	if err := c.ShouldBindJSON(&lot); err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to update lot"})
		return
	}
	initializers.DB.Save(&lot)
	c.JSON(http.StatusOK, lot)
}

// DeleteLot godoc
// @Summary Delete a lot
// @Description Delete a specific lot
// @Tags Lot
// @Produce json
// @Param id path int true "Lot ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/lots/{id} [delete]
func DeleteLot(c *gin.Context) {
	id := c.Param("id")
	if err := initializers.DB.Delete(&models.Lot{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to delete kermesse"})
		return
	}
	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}
