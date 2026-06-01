from fastapi import FastAPI, Depends, HTTPException, Header
import firebase_admin
from firebase_admin import credentials, auth
import os
from dotenv import load_dotenv

load_dotenv()

cred = credentials.Certificate(os.getenv("FIREBASE_KEY_PATH"))
firebase_admin.initialize_app(cred)

app = FastAPI()


def verify_firebase_token(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid auth header")

    token = authorization.split(" ")[1]

    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


@app.get("/")
def root():
    return {"status": "Backend running"}


@app.get("/profile")
def profile(user=Depends(verify_firebase_token)):
    return {
        "uid": user["uid"],
        "phone": user.get("phone_number"),
        "provider": user.get("firebase", {}).get("sign_in_provider")
    }


@app.post("/logout")
def logout():
    # Firebase logout is handled on client
    return {"message": "Logout handled on client"}
