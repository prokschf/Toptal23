I started with the Reacy+Redux and Lamda+Dynamo JS implementation
However I discovered that the back-end doesnt adhere to the API specs.
Specifically there were missing parameters like 'articlesCount' in GET /articles/

I saw that there is a similar implementation in Go, so I switched over to that one as a back-end

After deploying I discovered that this one did seem to adhere to the specs, however the React front-end was getting errors as well: it didn't seem to like that the taglist is returned as null instead of a list

However I already spent quite a lot of time on it and as it is not a real client project I decided to leave the react front-end at that.
So to demonstrate the working blog I also added an angular front-end that was in the go back-end repo.
This front-end doesn't have tests, so it is really only there for demonstration.

For a real client I would offer fixing the mismatch in the react front-end.

- how to reach
	- react staging:
	http://reactlambda-frontend-staging-www.s3-website.eu-central-1.amazonaws.com/
	- angular (only for demo purposes):
	http://react23test.s3-website.eu-central-1.amazonaws.com/#/

- diagram
	- front-end is react and deployed to s3
	- api gateway on top
	- lambdas for each endpoint in go
	- dynamo db tables for storage

- scaling considerations
	- lambda invocation limit
	- dynamo throughput

- security considerations
	- no scerets
	- IAM permissions could be tighter
	- security vulnerabilities found!

- how to add an endpoint
	- api_module
	
- stack
	github actions
	terraform
	
- terraform setup
	- s3 state
	- dynamo for lock
	
- repo structure
	- mono repo
	- terraform
	
- build triggers
	- on branch
	- db
	- backend
	- frontend

- logs
	- cloudwatch log groups for lambdas
	- cloudwatch log group for api gateway
	
- backup
	- PIT recovery enabled for 35 days