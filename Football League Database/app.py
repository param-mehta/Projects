#!/usr/bin/env python
# coding: utf-8

from flask import Flask,render_template, request,redirect,session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.exceptions import default_exceptions, HTTPException, InternalServerError
from werkzeug.security import check_password_hash, generate_password_hash
from sqlalchemy import create_engine
import pyodbc
from helpers import apology, login_required, authentication_required
from datetime import datetime

app = Flask(__name__)

app.config["TEMPLATES_AUTO_RELOAD"] = True
app.config["SESSION_FILE_DIR"] = mkdtemp()
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)


#engine = create_engine("mssql+pyodbc://DESKTOP-4R1D7CP/Football?driver=SQL+Server?Trusted_Connection=yes")
#con = engine.connect()

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=DESKTOP-4R1D7CP;'
                      'Database=Football;'
                      'Trusted_Connection=yes;')
cursor = conn.cursor()

logged_in = 0
users = {'param':'par','ashish':'ash'}
auth_code = 'xyz123'



@app.route("/login",methods = ['GET','POST'])
def login():
    session.clear()
    if request.method == 'GET':
        return render_template('login.html')
    else:
        username = request.form.get("username")
        password = request.form.get("password")
		# res = cursor.execute("SELECT * FROM users where username = :username",(username)).fetchall()
        res = cursor.execute("SELECT * FROM users where username = ?",(username)).fetchall()
        if len(res) != 1 or not check_password_hash(res[0][2],password):
            return apology("Invalid username or password")
        session["user_id"] = res[0][0]
        return redirect("/")

@app.route("/authenticate",methods = ['GET','POST'])
def authenticate():
    if request.method == 'GET':
        return render_template('authenticate.html')
    else:
        code = request.form.get("code")
        if code == auth_code:
            session["authenticated"] = 1
            return redirect('/register')
        else:
            return apology("Authentication Failed!")

@app.route("/register",methods = ['GET','POST'])
@authentication_required
def register():
    if request.method == 'GET':
        return render_template('register.html')
    else:
        username = request.form.get("username")
        password = request.form.get("password")
        password2 = request.form.get("password-repeat")
        res = cursor.execute("SELECT * FROM users where username = ?",(username)).fetchall()
        print(username,' ',password,' ',password2)
        if password != password2:
            return apology("The two passwords do not match!")
        if len(res) == 1:
            return apology("Username not available")
        hash = generate_password_hash(password)
        cursor.execute("insert into users(username,password_hash) values(?,?)",(username,hash))
        print('bye')
        conn.commit()
        return redirect('/login')



#users is a dictionary that maps username to their passwords
@app.route("/")
@login_required
def index():
    res = cursor.execute("select count(Matchday) from Scores").fetchall()
    matches = res[0][0]
    percent = round((matches*100/12))
    hist = cursor.execute("select * from history").fetchall()
    return render_template('index.html',matches = matches,percent = percent, hist = hist)


@app.route("/coaches")
@login_required
def coaches():
	res = cursor.execute("select * from Coach").fetchall()
	conn.commit()
	return render_template('coaches.html',res = res)

@app.route("/players")
@login_required
def players():
	res = cursor.execute("select * from Player").fetchall()
	conn.commit()
	return render_template('players.html',res = res)

@app.route("/stadiums")
@login_required
def stadiums():
	res = cursor.execute("select * from Stadium").fetchall()
	conn.commit()
	return render_template('stadiums.html',res = res)

@app.route("/teams")
@login_required
def teams():
	res = cursor.execute("select * from Team").fetchall()
	conn.commit()
	return render_template('teams.html',res = res)

@app.route("/scores")
@login_required
def scores():
	res = cursor.execute("select * from Scores").fetchall()
	conn.commit()
	return render_template('scores.html',res = res)

@app.route("/fixtures")
@login_required
def fixtures():
	res = cursor.execute("select * from Fixtures").fetchall()
	conn.commit()
	return render_template('fixtures.html',res = res)


@app.route("/points")
@login_required
def points():
	res = cursor.execute("select * from Points_Table ORDER BY Points DESC").fetchall()
	conn.commit()
	return render_template('points.html',res = res)

@app.route("/view_tables")
@login_required
def view_tables():
	return render_template('view_tables.html')



@app.route("/add_scores", methods = ['GET','POST'])
@login_required
def add_scores():
    if request.method == 'GET':
        return render_template('add_scores.html')
    else:
        matchday = request.form.get('matchday')
        homeid = request.form.get('homeid')
        homescore = request.form.get('homescore')
        awayid = request.form.get('awayid')
        awayscore = request.form.get('awayscore')
        cursor.execute("EXEC Update_Score ?,?,?,?,?;",(matchday,homeid,homescore,awayid,awayscore))
        cursor.execute("insert into history(id,dateofchange,matchday) values(?,?,?)",(session['user_id'],datetime.now(),matchday))
        conn.commit()
        return redirect('/add_scores')

@app.route("/edit_scores", methods = ['GET','POST'])
@login_required
def edit_scores():
	if request.method == 'GET':
		return render_template('edit_scores.html')
	else:
            matchday = request.form.get('matchday')
            homeid = request.form.get('homeid')
            homescore = request.form.get('homescore')
            awayid = request.form.get('awayid')
            awayscore = request.form.get('awayscore')
            cursor.execute("EXEC Edit_Score ?,?,?,?,?;",(matchday,homeid,homescore,awayid,awayscore))
            cursor.execute("insert into history(id,dateofchange,matchday) values(?,?,?)",(session['user_id'],datetime.now(),matchday))
            conn.commit()
            return redirect('/edit_scores')


@app.route("/logout")
@login_required
def logout():
    """Log user out"""
    session.clear()
    return redirect("/login")

# engine = create_engine('sqlite:///Chinook.sqlite')
# with engine.connect() as con:
#     rs = cursor.execute("select * from Employee where EmployeeID >= 6")
#     df = pd.DataFrame(rs.fetchall())
#     df.columns = rs.keys()
