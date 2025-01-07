# %%
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
df = pd.read_csv("Iris.csv", sep=",")
clf = LogisticRegression()

X = df
y = df['Species']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
X_train_data = X_train.iloc[:, 1:5]
X_test_data = X_test.iloc[:, 1:5]
clf.fit(X_train_data, y_train)
pred = clf.predict(X_test_data)
sub = pd.DataFrame(data=X_test)
sub['pred'] = pred
sub.head()  # Shows the first few rows

# %%
