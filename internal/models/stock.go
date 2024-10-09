package models

type Stock struct {
	ID           uint `gorm:"primary_key" json:"id"`
	StandID      uint
	Stand        Stand
	NomProduit   string
	Quantite     int
	PrixEnJetons int
}
