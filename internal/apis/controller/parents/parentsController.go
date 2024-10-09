package parents

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"net/http"
	"strconv"
	"errors"
    "gorm.io/gorm"

	"github.com/gin-gonic/gin"
)

// GetChildren godoc
// @Summary Get a specific children
// @Description Retrieve details of a children
// @Tags Parents
// @Produce json
// @Param id path int true "Children ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/children/{id} [get]
func GetChildren(c *gin.Context) {
	id := c.Param("id")
	var enfant models.Eleve
	if err := initializers.DB.Preload("User").First(&enfant, id).Error; err != nil {
        c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Enfant or associated user not found"})
        return
	}

	c.JSON(http.StatusOK, enfant)
}

// GetUserIdParent godoc
// @Summary Get id parent info
// @Description Retrieve information about the currently authenticated user
// @Tags Parents
// @Produce json
// @Success 200 {object} response.SuccessResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/parents/user/me [get]
func GetParentId(c *gin.Context) {
	parentID := c.Param("id")

	 var parent models.Parent
        if err := initializers.DB.
            Preload("User").  // Précharge les informations de l'utilisateur lié
            Preload("Enfants").  // Précharge les enfants
            Preload("Enfants.User").  // Précharge les informations utilisateur de chaque enfant
            First(&parent, parentID).Error; err != nil {
            if errors.Is(err, gorm.ErrRecordNotFound) {
                c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Parent not found"})
            } else {
                c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Error retrieving parent"})
            }
            return
        }

        // Créez une structure pour la réponse qui n'inclut pas les champs sensibles
        type SafeUser struct {
            ID           uint   `json:"id"`
            Name         string `json:"name"`
            Email        string `json:"email"`
            SoldeJetons  int64    `json:"solde_jetons"`
        }

        type SafeChild struct {
            ID   uint     `json:"id"`
            ParentID   uint     `json:"parent_id"`
            UserID   uint     `json:"user_id"`
            PointsAccumules int `json:"points_accumules"`
            User SafeUser `json:"user"`
        }

        type SafeParent struct {
            ID      uint       `json:"id"`
            UserID   uint     `json:"user_id"`
            User    SafeUser   `json:"user"`
            Enfants []SafeChild `json:"enfants"`
        }

        safeParent := SafeParent{
            ID: parent.ID,
            UserID: parent.User.ID,
            User: SafeUser{
                ID:          parent.User.ID,
                Name:        parent.User.Name,
                Email:       parent.User.Email,
                SoldeJetons: parent.User.SoldeJetons,
            },
            Enfants: make([]SafeChild, len(parent.Enfants)),
        }

        for i, enfant := range parent.Enfants {
            safeParent.Enfants[i] = SafeChild{
                ID: enfant.ID,
                ParentID: parent.ID,
                UserID: enfant.User.ID,
                PointsAccumules : enfant.PointsAccumules,
                User: SafeUser{
                    ID:          enfant.User.ID,
                    Name:        enfant.User.Name,
                    Email:       enfant.User.Email,
                    SoldeJetons: enfant.User.SoldeJetons,

                },
            }
        }

        c.JSON(http.StatusOK, safeParent)
    }


// GetChildrenByParent godoc
// @Summary Get a child by a parent
// @Description Get a children by parents
// @Tags Parents
// @Produce json
// @Param id path int true "Parent ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/parents/{id}/children [get]
func GetChildrenForParent(c *gin.Context) {
    parentID, _ := strconv.Atoi(c.Param("id"))

    var parent models.Parent
    if err := initializers.DB.Preload("Enfants").First(&parent, parentID).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Parent not found"})
        return
    }

    c.JSON(http.StatusOK, parent.Enfants)
}


// GetChildrenAllInteractionByParent godoc
// @Summary Get a child by a parent
// @Description Get a children by parents
// @Tags Parents
// @Produce json
// @Param id path int true "Enfant ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/children/{id}/interactions [get]
func GetChildInteractions(c *gin.Context) {
    childID, _ := strconv.Atoi(c.Param("id"))

    // D'abord, récupérez l'élève pour obtenir son UserID
    var eleve models.Eleve
    if err := initializers.DB.First(&eleve, childID).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Eleve not found"})
        return
    }

    // Ensuite, utilisez le UserID de l'élève pour rechercher les transactions
    var interactions []models.JetonTransaction
    if err := initializers.DB.Where("user_id = ?", eleve.UserID).Find(&interactions).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch interactions"})
        return
    }

    c.JSON(http.StatusOK,interactions)
}


// GetAllInteractionAndChildrenByParent godoc
// @Summary Get a child by a parent
// @Description Get a children by parents
// @Tags Parents
// @Produce json
// @Param id path int true "Parent ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/parents/{id}/children/interactions [get]
func GetAllChildrenInteractionsForParent(c *gin.Context) {
    parentID, _ := strconv.Atoi(c.Param("id"))

    var parent models.Parent
    if err := initializers.DB.Preload("Enfants").First(&parent, parentID).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Parent not found"})
        return
    }

    var allInteractions []models.JetonTransaction
    for _, child := range parent.Enfants {
        var interactions []models.JetonTransaction
        if err := initializers.DB.Where("user_id = ?", child.ID).Find(&interactions).Error; err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch interactions"})
            return
        }
        allInteractions = append(allInteractions, interactions...)
    }

    c.JSON(http.StatusOK, allInteractions)
}