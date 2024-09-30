package requests

import "time"

type RegisterRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Role     string `json:"role" binding:"required"`
}
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
}

type AddChildRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Role     string `json:"role" binding:"required"`
}

type CreateStandRequest struct {
	Nom             string `json:"nom" binding:"required"`
	Type            string `json:"type" binding:"required"`
	KermesseID      uint   `json:"kermesse_id" binding:"required"`
	TeneurID        uint   `json:"teneur_id" binding:"required"`
	PositionX       int    `json:"position_x"`
	PositionY       int    `json:"position_y"`
	JetonsCollectes int    `json:"jetons_collectes"`
	PointsAttribues int    `json:"points_attribues"`
}

type CreateTombolaRequest struct {
	Nom        string `json:"nom" binding:"required"`
	KermesseID uint   `json:"kermesse_id" binding:"required"`
}

type CreateJetonsTransactionRequest struct {
	Description string    `json:"description" binding:"required"`
	Type        string    `json:"type" binding:"required"`
	Montant     int       `json:"montant"`
	Date        time.Time `json:"date"`
	UserID      uint      `json:"user_id" binding:"required"`
	StandID     *uint     `json:"stand_id" binding:"required"`
}

type BuyJetonsRequest struct {
	UserID uint    `json:"user_id" example:"1"`
	Amount float64 `json:"amount" example:"50.00"`
}

type AttributeJetonsRequest struct {
	ParentID uint `json:"parent_id" example:"1"`
	ChildID  uint `json:"child_id" example:"2"`
	Amount   int  `json:"amount" example:"20"`
}

type PaymentRequest struct {
	UserID   uint `json:"user_id" binding:"required"`
	StandID  uint `json:"stand_id" binding:"required"`
	Quantity int  `json:"quantity" binding:"required,gt=0"`
}
