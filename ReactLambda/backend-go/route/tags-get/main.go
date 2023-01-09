package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"../../model"
	"../../service"
	"../../util"
)

type Response struct {
	Tags []string `json:"tags"`
}

func Handle(input events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	tags, err := service.GetTags()
	if err != nil {
		return util.NewErrorResponse(err)
	}

	response := Response{
		Tags: tags,
	}

	return util.NewSuccessResponse(200, response)
}

func main() {
	lambda.Start(Handle)
}
