package models

type StandType int

const (
	StandNourriture StandType = iota
	StandBoisson
	StandActivite
)

func (t StandType) String() string {
	return [...]string{"NOURRITURE", "BOISSON", "ACTIVITES"}[t]
}

type Stand struct {
	ID              uint      `gorm:"primary_key" json:"id"`
	Nom             string    `json:"nom"`
	Type            StandType `json:"type"`
	KermesseID      uint
	Kermesse        Kermesse
	TeneurID        uint
	Teneur          TeneurStand
	Stocks          []Stock
	PositionX       int `json:"position_x"`
	PositionY       int `json:"position_y"`
	JetonsCollectes int `json:"jetons_collectes"`
	PointsAttribues int `json:"points_attribues"` // Pour les activités
}
