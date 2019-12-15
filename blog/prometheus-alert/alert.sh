endsAt="$(date -r $(($(date +%s) + 10)) -u +"%Y-%m-%dT%H:%M:%SZ")"

curl -XPOST --header 'Content-Type: application/json' \
    http://0.0.0.0:9093/api/v1/alerts \
    -d'[
   {
     "labels": {
        "alertname": "UnreachableURL",
        "datacenter": "paris",
        "instance": "https://www.carnage.sh"
      },
      "annotations": {
         "info": "The URL for the nginx service is unavailable",
         "summary": "Please check the website is currently up and running..."
      },
      "endsAt": "'$endsAt'"
   }
 ]'



