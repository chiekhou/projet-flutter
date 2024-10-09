package gagnant

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// GetGagnants godoc
// @Summary Get all gagnants
// @Description Retrieve a list of all gagnantd
// @Tags Gagnant
// @Produce json
// @Param id path int true "Tombola ID"
// @Success 200 {array} models.Gagnant
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/gagnants [get]
func GetWinners(c *gin.Context) {
	tombolaID, _ := strconv.Atoi(c.Param("tombola_id"))
	var winners []models.Gagnant
	if err := initializers.DB.Where("tombola_id = ?", tombolaID).Preload("User").Preload("Lot").Find(&winners).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve gagnants"})
		return
	}
	c.JSON(http.StatusOK, winners)
}

// GetGagnant godoc
// @Summary Get a specific gagnant
// @Description Retrieve details of a specific gagnant of tombola
// @Tags Gagnant
// @Produce json
// @Param id path int true "Tombola ID"
// @Param id path int true "Gagnant ID"
// @Success 200 {object} models.Gagnant
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/tombolas/{id}/gagnants/{id} [get]
func GetWinner(c *gin.Context) {
	id := c.Param("id")
	var winner models.Gagnant
	if err := initializers.DB.Preload("User").Preload("Lot").First(&winner, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Gagnant not found"})
		return
	}
	c.JSON(http.StatusOK, winner)
}
