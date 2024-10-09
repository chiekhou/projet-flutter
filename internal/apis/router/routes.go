package router

import (
	"example/hello/internal/apis/controller/auth"
	"example/hello/internal/apis/controller/gagnant"
	"example/hello/internal/apis/controller/jetons"
	"example/hello/internal/apis/controller/kermesses"
	"example/hello/internal/apis/controller/lot"
	"example/hello/internal/apis/controller/messages"
	"example/hello/internal/apis/controller/payment"
	"example/hello/internal/apis/controller/stands"
	"example/hello/internal/apis/controller/stock"
	"example/hello/internal/apis/controller/tombola"
	"example/hello/internal/apis/controller/users"
	"example/hello/internal/apis/controller/parents"
	"example/hello/internal/apis/middleware"
	"os"

	"github.com/gin-gonic/gin"
)

func PublicRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")
	api := r.Group("/api")
	{
		api.POST("/register", auth.Register)
		api.POST("/login", auth.Login)
		api.POST("/logout", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), auth.Logout)
	}

}

func UserRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")
	{
		api.POST("/users", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN"), users.CreateUser)
		api.GET("/users", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN"), users.GetUsers)
		api.GET("/users/me", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), users.GetUser)
		api.PUT("/users/me", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), users.UpdateUser)
		api.DELETE("/users/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN"), users.DeleteUser)
		api.GET("/users/:id/jeton-transactions", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "ORGANISATEUR"), jetons.GetUserTransactions)
		api.GET("/users/:id/messages", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "TENEUR_STAND", "ORGANISATEUR"), messages.GetUserMessages)
		api.GET("/users/:id/messages/unread", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "TENEUR_STAND", "ORGANISATEUR"), messages.GetUnreadMessages)
		api.GET("/conversations/:userId1/:userId2", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "TENEUR_STAND", "ORGANISATEUR"), messages.GetConversation)
		api.GET("/users/for-points-attribution", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("TENEUR_STAND"), users.GetUsersForPointsAttribution)
		api.GET("/users/activity-stands", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("TENEUR_STAND"), users.GetUsersForPointsAttribution)
		api.GET("/users/parents/students", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN","ORGANISATEUR"), users.GetAllStudentsWithParentsAndUsers)
		api.POST("/parents/me/children", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "PARENT"), auth.AddChildToParent)

	}
}

func ParentRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")
	{

        api.GET("/children/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN","PARENT","ORGANISATEUR"), parents.GetChildren)
        api.GET("/parents/user/me", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN","PARENT","ORGANISATEUR"), parents.GetParentId)
		api.GET("/parents/:id/children", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN","PARENT","ORGANISATEUR"), parents.GetChildrenForParent)
		api.GET("/children/:id/interactions", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "PARENT", "ORGANISATEUR"), parents.GetChildInteractions)
		api.GET("/parents/:id/children/interactions", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "PARENT", "ORGANISATEUR"), parents.GetAllChildrenInteractionsForParent)

	}
}


func KermesseRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")

	{
		api.POST("/kermesses", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), kermesses.CreateKermesse)
		api.GET("/kermesses", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), kermesses.GetKermesses)
		api.GET("/kermesses/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), kermesses.GetKermesse)
		api.PUT("/kermesses/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), kermesses.UpdateKermesse)
		api.DELETE("/kermesses/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), kermesses.DeleteKermesse)
		api.GET("/kermesses/:id/plan", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), kermesses.GetKermessePlan)
		api.GET("/kermesses/:id/stands", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ADMIN", "ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR"), kermesses.GetKermesseStands)
	}

}

func StandRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")

	{
		api.POST("/stands", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.CreateStand)
		api.GET("/stands", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.GetAllStands)
		api.GET("/stands/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN", "PARENT","ELEVE"), stands.GetStand)
		api.PUT("/stands/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.UpdateStand)
		api.DELETE("/stands/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.DeleteStand)
		api.POST("/stands/:id/stock", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.ManageStock)
		api.POST("/stands/:id/jetons", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.CollectJetons)
		api.POST("/stands/points", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stands.AttributePoints)
		api.GET("/stands/:id/jeton-transactions", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), jetons.GetStandTransactions)
	}

}

func StockRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")

	{
		api.POST("/stands/:id/stocks", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stock.CreateStock)
		api.GET("/stocks", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("TENEUR_STAND", "ADMIN"), stock.GetAllStocks)
		api.GET("/stands/:id/stocks", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stock.GetStocksByStand)
		api.PUT("/stocks/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stock.UpdateStock)
		api.DELETE("/stocks/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stock.DeleteStock)
		api.POST("/stocks/:id/adjust", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), stock.AdjustStock)

	}

}

func TombolaRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")
	api := r.Group("/api")

	{
		api.POST("/kermesses/:id/tombolas", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), tombola.CreateTombola)
		api.GET("/kermesses/:id/tombolas", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN","ELEVE", "PARENT"), tombola.GetKermesseTombolas)
		api.GET("/tombolas/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN","ELEVE", "PARENT"), tombola.GetTombola)
		api.GET("/tombolas", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), tombola.GetAllTombolas)
		api.POST("/tombolas/:id/tickets", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("PARENT", "ELEVE", "ADMIN"), tombola.BuyTicket)
		api.GET("/tombolas/tickets", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), tombola.GetAllTickets)
		api.GET("/tombolas/:id/user/:userId/tickets", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "ELEVE", "PARENT"), tombola.GetUserTickets)
		api.POST("/tombolas/:id/draw", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), tombola.PerformDraw)
		api.GET("/tombolas/:id/gagnants", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "TENEUR_STAND", "ELEVE", "PARENT"), gagnant.GetWinners)
		api.GET("/tombolas/:id/gagnants/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "TENEUR_STAND", "ELEVE", "PARENT"), gagnant.GetWinner)
		api.POST("/tombolas/:id/lots", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), lot.CreateLot)
		api.GET("/tombolas/:id/lots", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "TENEUR_STAND", "ELEVE", "PARENT"), lot.GetLots)
		api.PUT("/tombolas/lots/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), lot.UpdateLot)
		api.DELETE("/tombolas/lots/:id", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), lot.DeleteLot)

	}

}
func JetonsTransactionRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")
	api := r.Group("/api")

	{
		api.POST("/jeton-transactions", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN"), jetons.CreateJetonTransaction)
		api.POST("/jeton-transaction/buy", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "PARENT", "ELEVE"), jetons.BuyJetons)
		api.POST("/jeton-transaction/transfer", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "PARENT"), jetons.AttributeJetonsToChild)
		api.GET("/jeton-transactions/summary", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "PARENT"), jetons.GetTransactionSummary)
		api.POST("/jeton-transactions/pay-with-jetons", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "ADMIN", "PARENT", "ELEVE"), jetons.PayWithJetons)
	}

}

func MessageRoutes(r *gin.Engine) {
	secretKey := os.Getenv("SECRET_KEY")

	api := r.Group("/api")

	{
		api.POST("/messages", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), messages.SendMessage)
		api.PUT("/messages/:id/read", middleware.JWTProtected(secretKey), middleware.RBACMiddleware("ORGANISATEUR", "TENEUR_STAND", "ADMIN"), messages.MarkMessageAsRead)
		api.GET("/ws/:user_id", messages.HandleWebSocket)
	}

}

// SetupStripeWebhookRoute godoc
// @Summary Handle Stripe webhook events
// @Description Process incoming Stripe webhook events for payment status updates
// @Tags Payment
// @Accept json
// @Produce json
// @Param Stripe-Signature header string true "Stripe signature for webhook verification"
// @Success 200 {string} string "OK"
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/webhook/stripe [post]
func SetupStripeWebhookRoute(router *gin.Engine) {
	router.POST("/api/webhook/stripe", func(c *gin.Context) {
		payment.HandleStripeWebhook(c.Writer, c.Request)
	})
}
