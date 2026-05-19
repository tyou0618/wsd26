from fastapi import FastAPI
from pydantic import BaseModel


class CalcParams(BaseModel):

    # 演算子 "add", "sub", "mul", "div" などを入れる
    operator: str
    # 1つ目の数値
    operand1: float
    # 2つ目の数値
    operand2: float

app = FastAPI()

# トップページ
# URL: http://127.0.0.1:8010/
@app.get("/")
def read_root():

    return {"hello": "world"}


# GETメソッド版の計算API
# URL例: http://127.0.0.1:8010/calc?a=25&b=15
@app.get("/calc")
def get_calc(a: float = 0, b: float = 0):

    return {
        "add": a + b,
        "sub": a - b,
        "mul": a * b,
        "div": a / b if b != 0 else "can`t 0"
    }


@app.post("/calc")
def post_calc(params: CalcParams):

    op = params.operator
    a1 = params.operand1
    a2 = params.operand2


    if op == "add":
        ans = a1 + a2
    
    elif op == "sub":
        ans = a1 - a2

    elif op == "mul":
        ans = a1 * a2

    elif op == "div":
        if a2 == 0:
            return {"error": "can`t 0"}
        ans = a1 / a2

    else:
        return {"error": "error"}

    return {"ans": ans}