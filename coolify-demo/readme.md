# Deploying ROR Playground cluster to Coolify

## Coolify deployment instructions

1. Add a new Resource
- Git Based / Public Repository
```
https://github.com/beshu-tech/ror-sandbox
```

2. Please set "Build Pack" => **Docker Compose**

3. Set the "Base Directory":
```
/coolify-demo
```

4. You may see an error message "fatal: Remote branch main not found in upstream origin"
- go to the "Sources" (inner left menu) and choose `master` as your Branch
- Save the changes and go to General => Reload Compose File
- if this doesn't work; reload the page with F5, make sure the "Sources" are set properly and try again'

5. Add the domain in "General/Domains":
- fill the "Domains for Kbn Ror" with whatever domain you want to use e.g. `https://ror-demo.anaphora.it`

6. Set the following in "General/Build":
- use *Custom Build Command* as follows:
```
chmod +x coolify-demo/build_starter.sh && cd coolify-demo && ./build_starter.sh
```
And the *Custom Start Command*:
```
cd coolify-demo && docker compose up --no-build -d
```
- please also check ☑️ "Preserve Repository During Deployment" option

7. Save the changes and hit the ▶️ Deploy button

8. Wait until the deployment is finished, open the URL you've entered in your browser and use the demo credentials:
- `admin` as a username and password

Enjoy! 🚀

## Local development instructions

To start the stack locally, please use the following command in current directory:
```shell
docker compose -f docker-compose.yaml -f docker-compose.local.yaml up --build -d
```
- please note that you'll need to run the pre-deployment script one time to create dotenv file:
```shell
chmod +x set_env_vars.sh && ./set_env_vars.sh
```
