#!/bin/bash
# If your refresh token expires, get a new one by visiting the page
#
# https://account.box.com/api/oauth2/authorize?response_type=code&client_id=lzkfx3i061rn44dhtsjykl2orx97hbil&state=authenticated
#
# and re-authorizing your web app. Then, replace NEW_CODE on
# the line below with the code given in the response from Box, and execute
# the completed command within 30 seconds of receiving the response.
#
# curl https://api.box.com/oauth2/token -d 'grant_type=authorization_code&code={your code}&client_id=lzkfx3i061rn44dhtsjykl2orx97hbil&client_secret=2PEs01kwreL86LxKjBgOrWVUcKh5qSu7' -X POST
#
# Then you should be all set!

REFRESH_TOKEN=$( cat box_refresh_token.txt | sed 's/\"//g')
RESPONSE=`curl https://api.box.com/oauth2/token -d 'grant_type=refresh_token&refresh_token='$REFRESH_TOKEN'&client_id=lzkfx3i061rn44dhtsjykl2orx97hbil&client_secret=2PEs01kwreL86LxKjBgOrWVUcKh5qSu7' -X POST`
NEW_ACCESS_TOKEN=`echo $RESPONSE | ./JSON.sh | egrep '\[\"access_token\"\]' | cut -f2`
NEW_REFRESH_TOKEN=`echo $RESPONSE | ./JSON.sh | egrep '\[\"refresh_token\"\]' | cut -f2`
echo $RESPONSE
echo 'new access token = ' $NEW_ACCESS_TOKEN
echo 'new refresh token = ' $NEW_REFRESH_TOKEN
echo $NEW_ACCESS_TOKEN > box_access_token.txt
echo $NEW_REFRESH_TOKEN > box_refresh_token.txt
