FROM n8nio/n8n:latest

# Copy workflows into the container
COPY workflows /home/node/.n8n/workflows

# Set the working directory
WORKDIR /home/node

# Expose the port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]