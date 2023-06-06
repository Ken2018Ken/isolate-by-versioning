#!/bin/bash

cat > index.html <<EOF
<h1>Hello, Ninjas</h1>
<h2> This app is fetching the database url and the port to connect through </h2> 
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p ${server_port} &
 