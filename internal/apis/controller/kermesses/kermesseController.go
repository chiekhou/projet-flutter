package kermesses

import (
	"encoding/json"
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PlanInteractif struct {
	Stands     []StandInfo    `json:"stands"`
	Dimensions map[string]int `json:"dimensions"`
}

type StandInfo struct {
	ID       uint           `json:"id"`
	Nom      string         `json:"nom"`
	Type     string         `json:"type"`
	Position map[string]int `json:"position"`
}

func GenerateKermessePlansJSON() error {
	var kermesses []models.Kermesse
	if err := initializers.DB.Preload("Stands").Find(&kermesses).Error; err != nil {
		return err
	}

	plans := make(map[string]PlanInteractif)

	for _, kermesse := range kermesses {
		stands := make([]StandInfo, len(kermesse.Stands))
		for i, stand := range kermesse.Stands {
			stands[i] = StandInfo{
				ID:   stand.ID,
				Nom:  stand.Nom,
				Type: stand.Type.String(), // Assurez-vous que Type a une méthode String()
				Position: map[string]int{
					"x": stand.PositionX,
					"y": stand.PositionY,
				},
			}
		}

		plans[strconv.Itoa(int(kermesse.ID))] = PlanInteractif{
			Stands:     stands,
			Dimensions: map[string]int{"largeur": 1000, "hauteur": 1000},
		}
	}

	jsonData, err := json.MarshalIndent(plans, "", "  ")
	if err != nil {
		return err
	}

	return ioutil.WriteFile("./assets/json/kermesse_plans.json", jsonData, 0644)
}
func InitializeKermessePlans() {
	if err := GenerateKermessePlansJSON(); err != nil {
		log.Fatalf("Failed to generate kermesse plans JSON: %v", err)
	}

	if err := InitKermessePlans(); err != nil {
		log.Fatalf("Failed to load kermesse plans: %v", err)
	}
}

// Structure pour stocker tous les plans
var allKermessePlans map[string]map[string]interface{}

// Fonction d'initialisation à appeler au démarrage de l'application
func InitKermessePlans() error {
	data, err := ioutil.ReadFile("./assets/json/kermesse_plans.json")
	if err != nil {
		return err
	}

	return json.Unmarshal(data, &allKermessePlans)
}

// CreateKermesse godoc
// @Summary Create a new kermesse
// @Description Create a new kermesse with the provided information
// @Tags Kermesse
// @Accept json
// @Produce json
// @Param kermesse body models.Kermesse true "Kermesse data"
// @Success 201 {object} response.KermesseResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses [post]
func CreateKermesse(c *gin.Context) {
	var newKermesse models.Kermesse
	if err := c.ShouldBindJSON(&newKermesse); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	// Créer une tombola vide pour la kermesse
	//newKermesse.Tombola = &models.Tombola{}

	if err := initializers.DB.Create(&newKermesse).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create kermesse"})
		return
	}

	c.JSON(http.StatusCreated, response.KermesseResponse{
		ID:   newKermesse.ID,
		Nom:  newKermesse.Nom,
		Date: newKermesse.Date,
		Lieu: newKermesse.Lieu,
	})
}

// GetKermesses godoc
// @Summary Get all kermesses
// @Description Retrieve a list of all kermesses
// @Tags Kermesse
// @Produce json
// @Success 200 {array} response.KermesseResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses [get]
func GetKermesses(c *gin.Context) {
	var kermesses []models.Kermesse
	if err := initializers.DB.Find(&kermesses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve kermesses"})
		return
	}

	var kermesseResponses []response.KermesseResponse
	for _, kermesse := range kermesses {
		kermesseResponses = append(kermesseResponses, response.KermesseResponse{
			ID:   kermesse.ID,
			Nom:  kermesse.Nom,
			Date: kermesse.Date,
			Lieu: kermesse.Lieu,
		})
	}

	c.JSON(http.StatusOK, kermesseResponses)
}

// GetKermesse godoc
// @Summary Get a specific kermesse
// @Description Retrieve details of a specific kermesse
// @Tags Kermesse
// @Produce json
// @Param id path int true "Kermesse ID"
// @Success 200 {object} response.KermesseResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id} [get]
func GetKermesse(c *gin.Context) {
	id := c.Param("id")
	var kermesse models.Kermesse
	if err := initializers.DB.First(&kermesse, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Kermesse not found"})
		return
	}

	c.JSON(http.StatusOK, response.KermesseResponse{
		ID:   kermesse.ID,
		Nom:  kermesse.Nom,
		Date: kermesse.Date,
		Lieu: kermesse.Lieu,
	})
}

// UpdateKermesse godoc
// @Summary Update a kermesse
// @Description Update details of a specific kermesse
// @Tags Kermesse
// @Accept json
// @Produce json
// @Param id path int true "Kermesse ID"
// @Param kermesse body models.Kermesse true "Updated kermesse data"
// @Success 200 {object} response.KermesseResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id} [put]
func UpdateKermesse(c *gin.Context) {
	id := c.Param("id")
	var kermesse models.Kermesse
	if err := initializers.DB.First(&kermesse, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Kermesse not found"})
		return
	}

	if err := c.ShouldBindJSON(&kermesse); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	if err := initializers.DB.Save(&kermesse).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to update kermesse"})
		return
	}

	c.JSON(http.StatusOK, response.KermesseResponse{
		ID:   kermesse.ID,
		Nom:  kermesse.Nom,
		Date: kermesse.Date,
		Lieu: kermesse.Lieu,
	})
}

// DeleteKermesse godoc
// @Summary Delete a kermesse
// @Description Delete a specific kermesse
// @Tags Kermesse
// @Produce json
// @Param id path int true "Kermesse ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id} [delete]
func DeleteKermesse(c *gin.Context) {
	id := c.Param("id")
	var kermesse models.Kermesse
	if err := initializers.DB.First(&kermesse, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Kermesse not found"})
		return
	}

	if err := initializers.DB.Delete(&kermesse).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to delete kermesse"})
		return
	}

	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

// GetKermessePlan godoc
// @Summary Get the interactive plan of a kermesse
// @Description Retrieve the interactive plan of a specific kermesse
// @Tags Kermesse
// @Produce json
// @Param id path int true "Kermesse ID"
// @Success 200 {object} response.PlanResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id}/plan [get]
func GetKermessePlan(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid ID format"})
		return
	}

	var kermesse models.Kermesse
	if err := initializers.DB.Preload("Stands").First(&kermesse, id).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Kermesse not found"})
		return
	}

	plan := PlanInteractif{
		Stands:     make([]StandInfo, len(kermesse.Stands)),
		Dimensions: map[string]int{"largeur": 1000, "hauteur": 1000}, // Ajustez selon vos besoins
	}

	for i, stand := range kermesse.Stands {
		plan.Stands[i] = StandInfo{
			ID:   stand.ID,
			Nom:  stand.Nom,
			Type: stand.Type.String(),
			Position: map[string]int{
				"x": stand.PositionX,
				"y": stand.PositionY,
			},
		}
	}

	c.JSON(http.StatusOK, plan)
}

// GetKermesseStands godoc
// @Summary Get all stands of a kermesse
// @Description Retrieve a list of all stands for a specific kermesse
// @Tags Kermesse
// @Produce json
// @Param id path int true "Kermesse ID"
// @Success 200 {array} response.StandResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/kermesses/{id}/stands [get]
func GetKermesseStands(c *gin.Context) {
	id := c.Param("id")
	var stands []models.Stand
	if err := initializers.DB.Where("kermesse_id = ?", id).Find(&stands).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve stands"})
		return
	}

	var standResponses []response.StandResponse
	for _, stand := range stands {
		standResponses = append(standResponses, response.StandResponse{
			ID:   stand.ID,
			Nom:  stand.Nom,
			Type: stand.Type.String(),
		})
	}

	c.JSON(http.StatusOK, standResponses)
}
