package models

type TeneurStand struct {
	ID     uint `gorm:"primary_key" json:"id"`
	UserID uint `gorm:"uniqueIndex"`
	User   User `gorm:"constraint:OnDelete:CASCADE;"`
}
