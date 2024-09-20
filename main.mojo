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
from collections import List
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

    fn get_safe_moves(inout self) raises -> List[String]:
        var safe_moves = List[String]()
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
        # TODO: Figure out why value for moves has single apostrophe ' around
        # them. Seems like a type issue as it doesn't happen with info.
        result += str('"') + entry[].value.replace("'", "") + str('", ')
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
fn start(game_state: String) -> String:
    print(game_state)
    print("GAME START")
    var result = String("OK")
    return result


# end is called when your Battlesnake finishes a game
fn end(game_state: String) -> String:
    print("GAME OVER\n")
    var result = String("OK")
    return result


# move is called on every turn and returns your next move
# Valid moves are "up", "down", "left", or "right"
# See https://docs.battlesnake.com/api/example-move for available data
def move(game_state_raw: String) -> String:
    is_move_safe = IsMoveSafe(True, True, True, True)

    var json = Python.import_module("json")
    game_state = json.loads(game_state_raw)

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
    var safe_moves: List[String] = is_move_safe.get_safe_moves()

    if len(safe_moves) == 0:
        print("MOVE {game_state['turn']}: No safe moves detected! Moving down")
        var result = Dict[String, String]()
        var cur_move = str("down")
        result["move"] = cur_move
        return dict_to_str(result)

    # Choose a random move from the safe ones
    var rand_idx = int(random_ui64(0, len(safe_moves) - 1))
    next_move = str(safe_moves[rand_idx])

    # TODO: Step 4 - Move towards food instead of random, to regain health and survive longer
    # food = game_state['board']['food']

    # TODO: Fix after you fix string to Dict
    # msg = "MOVE "
    #     + str(game_state['turn'])
    #     + ": "
    #     + str(next_move)
    # print(msg)
    var result = Dict[String, String]()
    result["move"] = next_move
    return dict_to_str(result)


@value
struct SnakeRouter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var raw_raw: String = req.body_raw
        var body_raw = str(raw_raw)
        var delimiter = "\r\n\r\n"
        var comb = body_raw.split(delimiter)
        var header = comb[0] + "\n"
        # Add closing paren as it is dropped for some reason.
        # TODO: Collapse paren add into every call if works. 
        var body = comb[0] + "}"
        if len(comb) == 2:
            body = comb[1] + "}"

        var uri = req.uri()

        if uri.path() == "/":
            return OK(info().as_bytes(), "application/json")
        elif uri.path() == "/start":
            return OK(start(body).as_bytes(), "text/plain")
        elif uri.path() == "/move":
            return OK(move(body).as_bytes(), "application/json")
        elif uri.path() == "/end":
            return OK(end(body).as_bytes(), "text/plain")

        return OK(
            str("Choose a different endpoint!").as_bytes(), "text/plain"
        )


# Start server when `mojo main.mojo` is run
fn main() raises:
    var server = SysServer()
    var handler = SnakeRouter()
    server.listen_and_serve("0.0.0.0:8000", handler)
