# Welcome to
# __________         __    __  .__                               __
# \______   \_____ _/  |__/  |_|  |   ____   ______ ____ _____  |  | __ ____
#  |    |  _/\__  \\   __\   __\  | _/ __ \ /  ___//    \\__  \ |  |/ // __ \
#  |    |   \ / __ \|  |  |  | |  |_\  ___/ \___ \|   |  \/ __ \|    <\  ___/
#  |________/(______/__|  |__| |____/\_____>______>___|__(______/__|__\\_____>
#
# This file can be a nice home for your Battlesnake logic and helper functions.
#
# To get you started we've included code to prevent your Battlesnake from moving backwards.
# For more info see docs.battlesnake.com

from python import Python
from collections.dict import Dict
from random import random_ui64

# from server_mojo import SnakeRouter

from lightbug_http.http import HTTPRequest, HTTPResponse, OK
from lightbug_http.service import HTTPService
from lightbug_http.sys.server import SysServer


struct IsMoveSafe:
    var up: Bool
    var down: Bool
    var left: Bool
    var right: Bool

    fn __init__(inout self, up: Bool, down: Bool, left: Bool, right: Bool):
        self.up = up
        self.down = down
        self.left = left
        self.right = right

    fn get_safe_moves(inout self) raises -> object:
        var safe_moves = object([])
        if self.up:
            safe_moves.append("up")
        if self.down:
            safe_moves.append("down")
        if self.left:
            safe_moves.append("left")
        if self.right:
            safe_moves.append("right")

        return safe_moves

    fn any_safe_moves(inout self, safe_moves: object) raises -> Bool:
        return len(safe_moves) > 0

fn dict_to_str(d: Dict[String, String]) -> String:
    var result = String("{") 
    for entry in d.items(): 
        result += str('"') + entry[].key + str('": ') 
        result += str('"') + entry[].value + str('", ')
    result = result[:-2] + String("}")
    return result

# info is called when you create your Battlesnake on play.battlesnake.com
# and controls your Battlesnake's appearance
# TIP: If you open your Battlesnake URL in a browser you should see this data
fn info() -> String:
    print("INFO")
    var result = Dict[String, String]()
    result["apiversion"] = "1"
    result["author"] = ""  # TODO: Your Battlesnake Username
    result["color"] = "#888888"  # TODO: Choose color
    result["head"] = "default"  # TODO: Choose head
    result["tail"] = "default"  # TODO: Choose tail

    return dict_to_str(result)


# start is called when your Battlesnake begins a game
def start(game_state: List[SIMD[DType.int8, 1]]):
    print("GAME START")


# end is called when your Battlesnake finishes a game
def end(game_state: List[SIMD[DType.int8, 1]]):
    print("GAME OVER\n")

# move is called on every turn and returns your next move
# Valid moves are "up", "down", "left", or "right"
# See https://docs.battlesnake.com/api/example-move for available data
def move(game_state) -> String:
    is_move_safe = IsMoveSafe(True, True, True, True)

    # We've included code to prevent your Battlesnake from moving backwards
    my_head = game_state["you"]["body"][0]  # Coordinates of your head
    my_neck = game_state["you"]["body"][1]  # Coordinates of your "neck"

    if my_neck["x"] < my_head["x"]:  # Neck is left of head, don't move left
        is_move_safe.left = False

    elif my_neck["x"] > my_head["x"]:  # Neck is right of head, don't move right
        is_move_safe.right = False

    elif my_neck["y"] < my_head["y"]:  # Neck is below head, don't move down
        is_move_safe.down = False

    elif my_neck["y"] > my_head["y"]:  # Neck is above head, don't move up
        is_move_safe.up = False

    # TODO: Step 1 - Prevent your Battlesnake from moving out of bounds
    # board_width = game_state['board']['width']
    # board_height = game_state['board']['height']

    # TODO: Step 2 - Prevent your Battlesnake from colliding with itself
    # my_body = game_state['you']['body']

    # TODO: Step 3 - Prevent your Battlesnake from colliding with other Battlesnakes
    # opponents = game_state['board']['snakes']

    # Are there any safe moves left?
    safe_moves = is_move_safe.get_safe_moves()

    if safe_moves.__len__() == 0:
        print("MOVE {game_state['turn']}: No safe moves detected! Moving down")
        var result = Dict[String, String]()
        result["move"] = "down"
        return dict_to_str(result)

    # Choose a random move from the safe ones
    var rand_idx = random_ui64(0, safe_moves.__len__())
    next_move = safe_moves[rand_idx]

    # TODO: Step 4 - Move towards food instead of random, to regain health and survive longer
    # food = game_state['board']['food']

    msg = "MOVE " 
        + str(game_state['turn'])
        + ": "
        + str(next_move)
    print(msg)
    var result = Dict[String, String]()
    result["move"] = next_move
    return dict_to_str(result)


@value
struct SnakeRouter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var body = req.body_raw
        var uri = req.uri()

        if uri.path() == "/":
            return OK(info().as_bytes(), "application/json")
        elif uri.path() == "/start":
            return OK(info().as_bytes(), "application/json")
            # return OK(start(body).as_bytes(), "application/json")
        elif uri.path() == "/move":
            return OK(info().as_bytes(), "application/json")
            # return OK(move(body).as_bytes(), "application/json")
        elif uri.path() == "/end":
            return OK(info().as_bytes(), "application/json")
            # return OK(end(body).as_bytes(), "application/json")

        return OK(String("Choose a different endpoint!").as_bytes(), "text/plain")

# Start server when `python main.py` is run
fn main() raises:
    # Python.add_to_path("")
    # var server = Python.import_module("server")
    # var payload = Dict[String, String]()
    # payload["info"] = info
    # payload["start"] = start
    # payload["move"] = move
    # payload["end"] = end

    # server.run_server(payload)

    # Mojo version here
    var server = SysServer()
    var handler = SnakeRouter()
    server.listen_and_serve("0.0.0.0:8000", handler)
