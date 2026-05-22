package api

import (
	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	r.GET("/health", HealthHandler)

	v1 := r.Group("/api/v1")
	{
		v1.GET("/offers", ListOffers)
		v1.POST("/offers", CreateOffer)
		v1.GET("/requests", ListRequests)
		v1.POST("/requests", CreateRequest)
		v1.GET("/matches", ListMatches)
		v1.POST("/commitments", CreateCommitment)
	}

	return r
}

func HealthHandler(c *gin.Context) {
	c.JSON(200, gin.H{"status": "ok", "service": "lunar-broker"})
}

func ListOffers(c *gin.Context)   { c.JSON(200, gin.H{"offers": []interface{}{}}) }
func CreateOffer(c *gin.Context)  { c.JSON(201, gin.H{"offer": "created"}) }
func ListRequests(c *gin.Context) { c.JSON(200, gin.H{"requests": []interface{}{}}) }
func CreateRequest(c *gin.Context) { c.JSON(201, gin.H{"request": "created"}) }
func ListMatches(c *gin.Context)  { c.JSON(200, gin.H{"matches": []interface{}{}}) }
func CreateCommitment(c *gin.Context) { c.JSON(201, gin.H{"commitment": "created"}) }
