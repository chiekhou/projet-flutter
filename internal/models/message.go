package models

type Message struct {
	ID             uint `gorm:"primary_key" json:"id"`
	ExpediteurID   uint
	Expediteur     User
	DestinataireID uint
	Destinataire   User
	Contenu        string
	Lu             bool
}
