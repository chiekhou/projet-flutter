package response

import "time"

type SuccessResponse struct {
	Data bool `json:"data"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type TokenResponse struct {
	Token string `json:"token"`
}

type UserResponse struct {
	ID    uint   `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Roles string `json:"roles"`
}

type KermesseResponse struct {
	ID   uint      `json:"id"`
	Nom  string    `json:"nom"`
	Date time.Time `json:"date"`
	Lieu string    `json:"lieu"`
}

type PlanResponse struct {
	ID             uint                   `json:"id"`
	PlanInteractif map[string]interface{} `json:"plan_interactif"`
}

type StandResponse struct {
	ID              uint   `json:"id"`
	Nom             string `json:"nom"`
	Type            string `json:"type"`
	KermesseID      uint   `json:"kermesse_id"`
	TeneurID        uint   `json:"teneur_id"`
	PositionX       int    `json:"position_x"`
	PositionY       int    `json:"position_y"`
	JetonsCollectes int    `json:"jetons_collectes"`
	PointsAttribues int    `json:"points_attribues"`
}

type LotResponse struct {
	ID          uint    `json:"id"`
	Nom         string  `json:"nom"`
	Description string  `json:"description"`
	Type        string  `json:"type"`
	Valeur      float64 `json:"valeur"`
}

type TombolaResponse struct {
	ID         uint   `json:"id"`
	Nom        string `json:"nom"`
	KermesseID uint   `json:"kermesse_id"`
}

type JetonCollectesResponse struct {
	Message     string `json:"message"`
	TotalJetons int64  `json:"total_jetons"`
}

type PointsAttribuesResponse struct {
	Message     string `json:"message"`
	TotalPoints int64  `json:"total_points"`
}

type SuccessAddChildResponse struct {
	Message string `json:"message"`
	Data    bool   `json:"data"`
}
