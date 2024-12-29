# Executable binary builder.
FROM golang:1.23.4-alpine AS Builder

# Installing git for it is a requirement to be able to fetch the dependancies.
# Installing SSL ca certificates to be able to call HTTPS endpoints.
RUN apk update && \
	apk add --no-cache git

# Setting the working directory.
WORKDIR $GOPATH/src/webapp/
# Copying the project files.
COPY . .

# Fetch dependancies using go get.
RUN go mod download
RUN go mod verify

# Build the binary for the webapp.
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/webapp

# Minimalistic small image as the final image with the sole purpose to run the binary.
FROM alpine:3.21.0
# Setting the working directory.
WORKDIR /webapp

COPY templates/ templates/
COPY assets/ assets/

# Installing shadow to have access to usermod command to be able to block shell access to root.
RUN apk add --update --no-cache --virtual .build-deps shadow && \
	usermod -s /usr/sbin/nologin root && \
	# Deleting the shadow package as it's job is done, and deleting the /var/cache/apk dir to have a slightly reduced image size.
	apk del .build-deps shadow && \
	rm -rf /var/cache/apk/* && \
	# Creating an unprivileged user that is meant to handle the running of the application.
	adduser --disabled-password \
			--shell /sbin/nologin \
			--no-create-home \
			--uid 10001 \
			appuser && \
	# Creating the secrets directory to pass kubernetes secrets as files.
	mkdir /secrets && \
	# Setting the unprivileged user as owner of the /secrets directory.
	chown -R appuser:appuser /secrets

# Get the built binary from the builder image.
COPY --from=Builder /go/bin/webapp /go/bin/webapp

# Use an unprivileged user.
USER appuser:appuser

# Run the built binary.
ENTRYPOINT ["/go/bin/webapp"]
