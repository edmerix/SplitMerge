function unhang(app,~)
delete(app.Data.loader);
app.refreshScreen();