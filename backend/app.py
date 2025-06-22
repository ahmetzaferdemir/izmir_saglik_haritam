from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# MySQL bağlantısı
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="saglikharitam"
)
cursor = db.cursor()

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    sifre = data.get('sifre')

    # Email zaten kayıtlı mı?
    cursor.execute("SELECT * FROM kullanici WHERE email = %s", (email,))
    existing_user = cursor.fetchone()
    if existing_user:
        return jsonify({"status": "fail", "message": "Bu email zaten kayıtlı."}), 409

    # Yeni kullanıcıyı ekle
    cursor.execute("INSERT INTO kullanici (email, sifre) VALUES (%s, %s)", (email, sifre))
    db.commit()

    return jsonify({"status": "success", "message": "Kayıt başarılı."}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    sifre = data.get('sifre')

    cursor.execute("SELECT * FROM kullanici WHERE email=%s AND sifre=%s", (email, sifre))
    user = cursor.fetchone()

    if user:
        return jsonify({"status": "success", "message": "Giriş başarılı."}), 200
    else:
        return jsonify({"status": "fail", "message": "Email veya şifre hatalı."}), 401

@app.route('/', methods=['GET'])
def test_api():
    return 'API ÇALIŞIYOR 🔥', 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)
# if __name__ == "__main__": app.run(host="0.0.0.0", port=5000)
