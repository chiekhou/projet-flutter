package models

type Role int

const (
	RoleEleve Role = iota
	RoleParent
	RoleTeneurStand
	RoleOrganisateur
	RoleAdmin
)

func (r Role) String() string {
	return [...]string{"ELEVE", "PARENT", "TENEUR_STAND", "ORGANISATEUR", "ADMIN"}[r]
}

type User struct {
	ID          uint   `gorm:"primary_key" json:"id"`
	Name        string `json:"name"`
	Email       string `json:"email" gorm:"uniqueIndex"`
	Password    string `json:"password"`
	Roles       Role   `json:"role"`
	SoldeJetons int64  `json:"solde_jetons"`
}
