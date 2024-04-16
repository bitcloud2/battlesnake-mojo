# Battlesnake Mojo Starter Project

A Battlesnake written in Mojo. Get started at [play.battlesnake.com](https://play.battlesnake.com).

This project is a great starting point for anyone wanting to program their first Battlesnake in Mojo. It can be run locally or easily deployed to a cloud provider of your choosing. See the [Battlesnake API Docs](https://docs.battlesnake.com/api) for more detail. 

## Technologies Used

This project uses [Python 3](https://www.python.org/), [Mojo](https://www.modular.com/max/mojo), and [Lightbug](https://github.com/saviorand/lightbug_http). It also comes with an optional [Dockerfile](https://docs.docker.com/engine/reference/builder/) to help with deployment.

## Run Your Battlesnake

Note: This is a hack until I can figure out a packaging issue.

Clone lightbug repo into separate directory.
Copy necessary directories into yours.

```sh
git clone https://github.com/saviorand/lightbug_http.git ../lightbug_http
cp -rf ../lightbug_http/lightbug_http .
cp -rf ../lightbug_http/external .
```

Start your Battlesnake

```sh
mojo main.mojo
```

You should see the following output once it is running

```sh
🔥🐝 Lightbug is listening on http://0.0.0.0:8000
Ready to accept connections...
```

Open [localhost:8000](http://localhost:8000) in your browser and you should see

```json
{"apiversion":"1","author":"","color":"#888888","head":"default","tail":"default"}
```

## Play a Game Locally (untested/probably won't work)

Install the [Battlesnake CLI](https://github.com/BattlesnakeOfficial/rules/tree/main/cli)
* You can [download compiled binaries here](https://github.com/BattlesnakeOfficial/rules/releases)
* or [install as a go package](https://github.com/BattlesnakeOfficial/rules/tree/main/cli#installation) (requires Go 1.18 or higher)

Command to run a local game

```sh
battlesnake play -W 11 -H 11 --name 'Python Starter Project' --url http://localhost:8000 -g solo --browser
```

## Next Steps

Continue with the [Battlesnake Quickstart Guide](https://docs.battlesnake.com/quickstart) to customize and improve your Battlesnake's behavior.

**Note:** To play games on [play.battlesnake.com](https://play.battlesnake.com) you'll need to deploy your Battlesnake to a live web server OR use a port forwarding tool like [ngrok](https://ngrok.com/) to access your server locally.
