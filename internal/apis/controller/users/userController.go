package users

import (
	"example/hello/internal/initializers"
	"example/hello/internal/models"
	"example/hello/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateUser godoc
// @Summary Create a new user
// @Description Create a new user with the provided information
// @Tags Users
// @Accept json
// @Produce json
// @Param user body models.User true "User data"
// @Success 201 {object} response.UserResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer Add access token here)
// @Router /api/users [post]
func CreateUser(c *gin.Context) {
	var newUser models.User
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	if err := initializers.DB.Create(&newUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, response.UserResponse{
		ID:    newUser.ID,
		Name:  newUser.Name,
		Email: newUser.Email,
		Roles: newUser.Roles.String(),
	})
}

// GetUsers godoc
// @Summary Get all users
// @Description Retrieve a list of all users
// @Tags Users
// @Produce json
// @Success 200 {array} response.UserResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users [get]
func GetUsers(c *gin.Context) {
	var users []models.User
	if err := initializers.DB.Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to retrieve users"})
		return
	}

	var userResponses []response.UserResponse
	for _, user := range users {
		userResponses = append(userResponses, response.UserResponse{
			ID:    user.ID,
			Name:  user.Name,
			Email: user.Email,
			Roles: user.Roles.String(),
		})
	}

	c.JSON(http.StatusOK, userResponses)
}

// GetUser godoc
// @Summary Get current user info
// @Description Retrieve information about the currently authenticated user
// @Tags Users
// @Produce json
// @Success 200 {object} response.UserResponse
// @Failure 404 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/me [get]
func GetUser(c *gin.Context) {
	userID, _ := c.Get("userID")
	var user models.User
	if err := initializers.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "User not found"})
		return
	}

	c.JSON(http.StatusOK, response.UserResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
		Roles: user.Roles.String(),
		SoldeJetons : user.SoldeJetons,
	})
}

// UpdateUser godoc
// @Summary Update current user info
// @Description Update information for the currently authenticated user
// @Tags Users
// @Accept json
// @Produce json
// @Param user body models.User true "Updated user data"
// @Success 200 {object} response.UserResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/me [put]
func UpdateUser(c *gin.Context) {
	userID, _ := c.Get("userID")
	var user models.User
	if err := initializers.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "User not found"})
		return
	}

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid request format"})
		return
	}

	if err := initializers.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, response.UserResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
		Roles: user.Roles.String(),
	})
}

// DeleteUser godoc
// @Summary Delete a user
// @Description Delete a user by ID
// @Tags Users
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/{id} [delete]
func DeleteUser(c *gin.Context) {
	userID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, response.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	var user models.User
	if err := initializers.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, response.ErrorResponse{Error: "User not found"})
		return
	}

	if err := initializers.DB.Delete(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to delete user"})
		return
	}

	c.JSON(http.StatusOK, response.SuccessResponse{Data: true})
}

// GetUsersForPointsAttribution godoc
// @Summary Get list of users for points attribution
// @Description Get a list of parents and students for attributing points
// @Tags Users
// @Accept json
// @Produce json
// @Success 200 {object} response.UsersListResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/for-points-attribution [get]
func GetUsersForPointsAttribution(c *gin.Context) {
    var parents []struct {
        ID     uint
        UserID uint
        PointsAccumules int
        Name   string
    }

    var students []struct {
        ID     uint
        UserID uint
        PointsAccumules int
        Name   string
    }

    if err := initializers.DB.Table("parents").
        Select("parents.id, parents.user_id, parents.points_accumules, users.name").
        Joins("JOIN users ON users.id = parents.user_id").
        Scan(&parents).Error; err != nil {
        c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to fetch parents"})
        return
    }

    if err := initializers.DB.Table("eleves").
        Select("eleves.id, eleves.user_id, eleves.points_accumules, users.name").
        Joins("JOIN users ON users.id = eleves.user_id").
        Scan(&students).Error; err != nil {
        c.JSON(http.StatusInternalServerError, response.ErrorResponse{Error: "Failed to fetch students"})
        return
    }

    usersList := response.UsersListResponse{
        Parents:  make([]response.UserInfo, len(parents)),
        Students: make([]response.UserInfo, len(students)),
    }

    for i, parent := range parents {
        usersList.Parents[i] = response.UserInfo{
            ID:     parent.ID,
            UserID: parent.UserID,
            Name:   parent.Name,
            PointsAccumules: parent.PointsAccumules,
            Type:   "parent",
        }
    }

    for i, student := range students {
        usersList.Students[i] = response.UserInfo{
            ID:     student.ID,
            UserID: student.UserID,
            Name:   student.Name,
            PointsAccumules: student.PointsAccumules,
            Type:   "student",
        }
    }

    c.JSON(http.StatusOK, usersList)
}

// GetActivityForUsers godoc
// @Summary Get list of users for activty
// @Description Get a list of parents and students for activity
// @Tags Users
// @Accept json
// @Produce json
// @Success 200 {object} response.SuccessResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/activity-stands [get]
func GetActivityStandsForUser(c *gin.Context) {
    userID, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }

    userType := c.Query("userType")
    if userType != "parent" && userType != "student" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user type"})
        return
    }

    var stands []models.Stand
    query := initializers.DB.Where("type = ?", models.StandActivite)

    if userType == "parent" {
        query = query.Joins("JOIN jeton_transactions ON jeton_transactions.stand_id = stands.id").
                      Joins("JOIN parents ON parents.user_id = jeton_transactions.user_id").
                      Where("parents.id = ?", userID)
    } else {
        query = query.Joins("JOIN jeton_transactions ON jeton_transactions.stand_id = stands.id").
                      Joins("JOIN eleves ON eleves.user_id = jeton_transactions.user_id").
                      Where("eleves.id = ?", userID)
    }

    if err := query.Distinct().Find(&stands).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve activity stands"})
        return
    }

    c.JSON(http.StatusOK, stands)
}

// GetUsers godoc
// @Summary Get all users
// @Description Retrieve a list of all users parents students
// @Tags Users
// @Produce json
// @Success 200 {array} response.UserResponse
// @Failure 500 {object} response.ErrorResponse
// @Security Bearer
// @Param Authorization header string true "Insert your access token" default(Bearer )
// @Router /api/users/parents/students [get]
func GetAllStudentsWithParentsAndUsers(c *gin.Context) {
    var students []models.Eleve
    if err := initializers.DB.Preload("Parent").Preload("Parent.User").Preload("User").Find(&students).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Échec de la récupération des élèves, parents et utilisateurs"})
        return
    }

    c.JSON(http.StatusOK, students)
}