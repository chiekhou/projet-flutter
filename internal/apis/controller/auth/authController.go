package auth

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/requests"
	"example/hello/response"
	"fmt"
	"os"
	"time"

	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Login godoc
// @Summary Allow you to log in and get a JWT Token
// @Description Login to the app
// @Tags Auth
// @Accept json
// @Produce json
// @Param user body requests.LoginRequest true "User credentials"
// @Success 200 {object} response.TokenResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/login [post]
func Login(c *gin.Context) {
	var loginReq requests.LoginRequest

	if err := c.ShouldBindJSON(&loginReq); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	var user models.User
	result := initializers.DB.Where("email = ?", loginReq.Email).First(&user)
	if result.Error != nil {
		c.JSON(http.StatusUnauthorized, response.ErrorResponse{Error: "Invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(loginReq.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, response.ErrorResponse{Error: "Invalid credentials"})
		return
	}

	token, err := generateJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, response.TokenResponse{Token: token})
}

func stringToRole(roleStr string) (models.Role, error) {
	switch roleStr {
	case "ELEVE":
		return models.RoleEleve, nil
	case "PARENT":
		return models.RoleParent, nil
	case "TENEUR_STAND":
		return models.RoleTeneurStand, nil
	case "ORGANISATEUR":
		return models.RoleOrganisateur, nil
	case "ADMIN":
		return models.RoleAdmin, nil
	default:
		return models.Role(0), fmt.Errorf("rôle invalide: %s", roleStr)
	}
}

// Register godoc
// @Summary Allow you to register as a new User
// @Description Create a new user with the provided information
// @Tags Auth
// @Accept json
// @Produce json
// @Param user body requests.RegisterRequest true "User data"
// @Success 201 {object} response.UserResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 409 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/register [post]
func Register(c *gin.Context) {
	var registerReq requests.RegisterRequest

	if err := c.ShouldBindJSON(&registerReq); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	// Vérification de l'existence de l'utilisateur
	var existingUser models.User
	result := initializers.DB.Where("email = ?", registerReq.Email).First(&existingUser)
	if result.Error == nil {
		c.JSON(http.StatusConflict, response.ErrorResponse{Error: "Email already in use"})
		return
	}

	// Conversion du rôle
	role, err := stringToRole(registerReq.Role)
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: err.Error()})
		return
	}

	// Hachage du mot de passe
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(registerReq.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to process password"})
		return
	}

	newUser := models.User{
		Name:     registerReq.Name,
		Email:    registerReq.Email,
		Password: string(passwordHash),
		Roles:    role,
	}

	// Commencer une transaction
	tx := initializers.DB.Begin()

	if err := tx.Create(&newUser).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create user"})
		return
	}

	// Créer l'entrée correspondante selon le rôle
	switch registerReq.Role {
	case "ELEVE":
		eleve := models.Eleve{
			UserID: newUser.ID,
		}
		if err := tx.Create(&eleve).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create eleve"})
			return
		}
	case "PARENT":
		parent := models.Parent{
			UserID: newUser.ID,
		}
		if err := tx.Create(&parent).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create parent"})
			return
		}

	case "ORGANISATEUR":
		organisateur := models.Organisateur{
			UserID: newUser.ID,
		}
		if err := tx.Create(&organisateur).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create organisateur"})

		}

	case "TENEUR_STAND":
		teneur := models.TeneurStand{
			UserID: newUser.ID,
		}
		if err := tx.Create(&teneur).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create teneur de stand"})

		}
	}

	// Commit la transaction
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to complete registration"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "User registered successfully", "userId": newUser.ID})

}

// AddChildToParent godoc
// @Summary Ajouter un enfant au profil du parent
// @Description Permet à un parent d'ajouter un enfant à son profil
// @Tags Parents
// @Accept json
// @Produce json
// @Param request body requests.AddChildRequest true "Informations de l'enfant"
// @Success 201 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/parents/me/children [post]
func AddChildToParent(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, response.ErrorResponse{Error: "User not authenticated"})
		return
	}

	var req requests.AddChildRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: err.Error()})
		return
	}

	// Hachage du mot de passe
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to process password"})
		return
	}

	tx := initializers.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Check if the user is a parent
	var parent models.Parent
	if err := tx.Where("user_id = ?", userID).First(&parent).Error; err != nil {
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "Parent not found for this user"})
		} else {
			c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to find parent"})
		}
		return
	}

	// Conversion du rôle
	role, err := stringToRole(req.Role)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: err.Error()})
		return
	}

	// Créer un nouvel utilisateur pour l'enfant
	childUser := models.User{
		Name:     req.Name,
		Email:    req.Email,
		Password: string(passwordHash),
		Roles:    role,
	}

	if err := tx.Create(&childUser).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create child user"})
		return
	}

	// Créer l'entité Eleve
	eleve := models.Eleve{
		UserID:   childUser.ID,
		ParentID: &parent.ID,
	}

	if err := tx.Create(&eleve).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create eleve record"})
		return
	}

	// Mise à jour de la relation Parent-Eleve
	if err := tx.Model(&parent).Association("Enfants").Append(&eleve); err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to link child to parent"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to complete child addition"})
		return
	}

	c.JSON(http.StatusCreated, response.SuccessAddChildResponse{
		Message: "Child added successfully",
		Data:    true,
	})
}

// @Summary Logout
// @Description Inform the client to delete the token
// @Tags Auth
// @Accept json
// @Produce json
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/logout [post]
func Logout(c *gin.Context) {
	// En l'absence de gestion des tokens côté serveur, rien n'est requis ici
	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

func generateJWT(user models.User) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":   user.ID,
		"role": user.Roles.String(),
		"exp":  time.Now().Add(time.Hour * 24).Unix(),
	})

	return token.SignedString([]byte(os.Getenv("SECRET_KEY")))
}
