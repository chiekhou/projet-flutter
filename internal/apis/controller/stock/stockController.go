package stock

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateStock godoc
// @Summary Create a new stock entry
// @Description Create a new stock entry for a stand
// @Tags Stock
// @Accept json
// @Produce json
// @Param id path int true "Stand ID"
// @Param stock body models.Stock true "Stock data"
// @Success 201 {object} models.Stock
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id}/stocks [post]
func CreateStock(c *gin.Context) {
	standID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	var stock models.Stock
	if err := c.ShouldBindJSON(&stock); err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create stock"})
		return
	}

	stock.StandID = uint(standID)

	if err := initializers.DB.Create(&stock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create stock entry"})
		return
	}

	c.JSON(http.StatusCreated, stock)
}

// GetStocksByStand godoc
// @Summary Get all stock entries for a stand
// @Description Retrieve all stock entries for a specific stand
// @Tags Stock
// @Produce json
// @Param id path int true "Stand ID"
// @Success 200 {array} models.Stock
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stands/{id}/stocks [get]
func GetStocksByStand(c *gin.Context) {
	standID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid stand ID"})
		return
	}

	var stocks []models.Stock
	if err := initializers.DB.Where("stand_id = ?", standID).Find(&stocks).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "No stocks found for this stand"})
		return
	}

	c.JSON(http.StatusOK, stocks)
}

// UpdateStock godoc
// @Summary Update a stock entry
// @Description Update an existing stock entry
// @Tags Stock
// @Accept json
// @Produce json
// @Param id path int true "Stock ID"
// @Param stock body models.Stock true "Updated stock data"
// @Success 200 {object} models.Stock
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stocks/{id} [put]
func UpdateStock(c *gin.Context) {
	id := c.Param("id")
	var stock models.Stock
	if err := initializers.DB.First(&stock, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stock not found"})
		return
	}

	if err := c.ShouldBindJSON(&stock); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	if err := initializers.DB.Save(&stock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to update stock"})
		return
	}

	c.JSON(http.StatusOK, stock)
}

// DeleteStock godoc
// @Summary Delete a stock entry
// @Description Delete an existing stock entry
// @Tags Stock
// @Produce json
// @Param id path int true "Stock ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stocks/{id} [delete]
func DeleteStock(c *gin.Context) {
	id := c.Param("id")
	var stock models.Stock
	if err := initializers.DB.First(&stock, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stock not found"})
		return
	}

	if err := initializers.DB.Delete(&stock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to delete stock"})
		return
	}

	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

// AdjustStock godoc
// @Summary Adjust stock quantity
// @Description Adjust the quantity of a stock entry (add or subtract)
// @Tags Stock
// @Accept json
// @Produce json
// @Param id path int true "Stock ID"
// @Param adjustment body models.Stock true "Stock adjustment data"
// @Success 200 {object} models.Stock
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/stocks/{id}/adjust [post]
func AdjustStock(c *gin.Context) {
	id := c.Param("id")
	var stock models.Stock
	if err := initializers.DB.First(&stock, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Stock not found"})
		return
	}

	var adjustment struct {
		Quantite int `json:"quantite"`
	}
	if err := c.ShouldBindJSON(&adjustment); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	stock.Quantite += adjustment.Quantite
	if stock.Quantite < 0 {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Stock quantity cannot be negative"})
		return
	}

	if err := initializers.DB.Save(&stock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to ajust stock"})
		return
	}

	c.JSON(http.StatusOK, stock)
}
