package main

import (
	initializers "example/hello/internal/initializers"
	"example/hello/internal/models"
)

func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDatabase()
}

func main() {
	//Drop la BDD afin de faire de nouvelle migrations
	/*initializers.DB.Migrator().DropTable(

		&models.User{},
		&models.Parent{},
		&models.Eleve{},
		&models.Organisateur{},
		&models.TeneurStand{},
		&models.Kermesse{},
		&models.Stand{},
		&models.Tombola{},
		&models.Lot{},
		&models.Stock{},
		&models.Ticket{},
		&models.Gagnant{},
		&models.JetonTransaction{},
		&models.Message{},
	)
	// Supprimer explicitement les tables de jointure
	initializers.DB.Migrator().DropTable("kermesse_lots", "kermesse_organisateurs", "kermesse_participants", "kermesse_stands", "stand_responsables", "stand_stock", "stand_responsables", "tombola_gagnant", "organisateur_kermesses", "tombola_lots", "tombola_tickets", "parents_eleves")*/

	err := initializers.DB.AutoMigrate(
		&models.User{},
		&models.Parent{},
		&models.Eleve{},
		&models.Organisateur{},
		&models.TeneurStand{},
		&models.Kermesse{},
		&models.Stand{},
		&models.Tombola{},
		&models.Lot{},
		&models.Stock{},
		&models.Ticket{},
		&models.Gagnant{},
		&models.JetonTransaction{},
		&models.Message{},
	)
	if err != nil {
		return
	}

}
