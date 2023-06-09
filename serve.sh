#!/bin/bash

# Help text for the program
help_text="
Usage: sh serve.sh -d [directory-path] [-p [port-number]]

OPTIONS:
    -d, --dir      The directory which you want to serve
    -p, --port     The local HTTP server port, default 8000
    -h, --help     Display this help text
"

# Set default values for the parameters
dir=""
port=8964
SERVER_PID_FILE="/tmp/serve_any_directory_8964.PID"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -d | --dir)
    dir="$2"
    shift
    ;;
  -p | --port)
    port="$2"
    shift
    ;;
  -h | --help)
    echo "$help_text"
    exit 0
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

# check if directory name is provided as argument
if [ -z "$dir" ]; then
  echo "$help_text"
  exit 1
fi

# check if the directory exists
if [ ! -d "$dir" ]; then
  echo "Directory $dir does not exist."
  exit 1
fi

# Print parameters
echo "Serve: $dir"
echo "Port:  $port"

# Clear old http server if it exists
if [ -f $SERVER_PID_FILE ]; then
  SERVER_PID=$(cat $SERVER_PID_FILE)
#  echo $SERVER_PID
  if kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    printf "Shutdown old http server..."
    kill "$SERVER_PID"
    echo "Done"
  fi
fi

# Check php environment
php_exe=''
if command -v php >/dev/null 2>&1; then
  php_exe='php'
fi
if command -v valet >/dev/null 2>&1; then
  php_exe='valet php'
fi

# check if the directory is a Laravel project directory
if [[ -f "$dir"/artisan && -n $php_exe ]]; then
  #echo "Starting Laravel server on port $port..."
  cd "$dir"
  $php_exe artisan serve --port "$port" &
  SERVER_PID=$!
else
  if [ -f "$dir"/artisan ]; then
    echo "+-------------------------------------------------------------------------------+"
    echo "| NOTICE: It is likely a Laravel project, but didn't detect PHP environment.    |"
    echo "| Use simple http server instead                                                |"
    echo "+-------------------------------------------------------------------------------+"
  fi

  echo "Starting Python server on port $port..."
  python -m http.server -d "$dir" "$port" &
  SERVER_PID=$!
fi

echo $SERVER_PID >"$SERVER_PID_FILE"

# start the Cloudflare tunnel
echo "Starting Cloudflare tunnel..."
cloudflared tunnel --url http://localhost:"$port"
TUNNEL_PID=$!

# wait for the tunnel to start
sleep 5

# print the public URL
#echo "Your site is now live at:"
#PUBLIC_URL="$(cloudflared tunnel info | grep -oE 'https://[^\"]+')"
#echo "$PUBLIC_URL"

#function ctrl_c() {
#    echo "Ctrl+C detected - exiting"
#    exit 1
#}

# trap the exit signal to stop the server and tunnel
#trap "echo 'Stopping server and tunnel...'; kill $SERVER_PID; cloudflared tunnel cleanup $PUBLIC_URL; exit 0" EXIT

# prompt to stop the serving
#echo "Press CTRL+C to stop serving..."
#read -n 1 -s

printf 'Shutdown the server...'
kill $SERVER_PID
echo 'Done'

# exit the script (the trap will catch the exit signal)
exit 0
