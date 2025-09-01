# Netflix Data Analysis Project

import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# -----------------------------
# Step 1 - Load Data
# -----------------------------
df = pd.read_csv("netflix.csv", encoding_errors='ignore')

# Basic cleaning
df.drop_duplicates(inplace=True)
df.dropna(subset=['show_id'], inplace=True)
df['date_added'] = pd.to_datetime(df['date_added'], errors='coerce')

# -----------------------------
# 1. Count the number of Movies and TV Shows
# -----------------------------
q1 = df.groupby('show_type')['show_id'].count().reset_index(name='total').sort_values('total')
print(q1)

# -----------------------------
# 2. Most common rating for movies and TV shows
# -----------------------------
q2 = df.groupby(['show_type','rating']).size().reset_index(name='rating_count')
q2['rank'] = q2.groupby('show_type')['rating_count'].rank(ascending=False, method='dense')
q2 = q2[q2['rank']==1].sort_values('show_type')
print(q2[['show_type','rating','rating_count']])

# -----------------------------
# 3. Movies released in 2020
# -----------------------------
q3 = df[(df['show_type']=='Movie') & (df['release_year']==2020)]
print(q3)

# -----------------------------
# 4. Top 5 countries with most content
# -----------------------------
# Take first country if multiple listed
df['primary_country'] = df['country'].str.split(',', expand=True)[0].str.strip()
q4 = df[df['primary_country'].notna() & (df['primary_country'] != '')] \
        .groupby('primary_country')['show_id'].count() \
        .reset_index(name='total_content') \
        .sort_values('total_content', ascending=False).head(5)
print(q4)

# -----------------------------
# 5. Identify the 5 longest movies
# -----------------------------
# Extract duration number from string
df['duration_num'] = df['duration'].str.extract('(\d+)').astype(float)
q5 = df[df['show_type']=='Movie'].sort_values('duration_num', ascending=False).head(5)
print(q5)

# -----------------------------
# 6. Content added in last 5 years
# -----------------------------
five_years_ago = pd.Timestamp.today() - pd.DateOffset(years=5)
q6 = df[df['date_added'] >= five_years_ago]
print(q6)

# -----------------------------
# 7. Movies/TV shows by Steven Spielberg
# -----------------------------
q7 = df[df['director'].str.contains('Steven Spielberg', na=False)]
print(q7)

# -----------------------------
# 8. TV shows with more than 5 seasons
# -----------------------------
q8 = df[(df['show_type']=='TV Show') & (df['duration_num']>5)]
print(q8)

# -----------------------------
# 9. Number of content items in each genre
# -----------------------------
genre_list = df['listed_in'].dropna().str.split(',', expand=True).stack().str.strip()
q9 = genre_list.value_counts().reset_index()
q9.columns = ['genre','total_titles']
print(q9)

# -----------------------------
# 10. Top 5 years with highest avg content released by India
# -----------------------------
q10 = df[df['country'].str.contains('India', na=False)]
total_india = len(q10)
year_count = q10.groupby('release_year')['show_id'].count().reset_index(name='total_release')
year_count['avg_release'] = round(year_count['total_release']/total_india*100,2)
q10 = year_count.sort_values('avg_release', ascending=False).head(5)
print(q10)

# -----------------------------
# 11. List all documentaries
# -----------------------------
q11 = df[df['listed_in'].str.contains('Documentaries', na=False)]
print(q11)

# -----------------------------
# 12. Find all content without a director
# -----------------------------
q12 = df[df['director'].isna() | (df['director']=='')]
print(q12)

# -----------------------------
# 13. Movies with Salman Khan in last 10 years
# -----------------------------
current_year = pd.Timestamp.today().year
q13 = df[df['casts'].str.contains('Salman Khan', na=False) & (df['release_year'] > current_year-10)]
print(q13)

# -----------------------------
# 14. Top 10 actors in Indian content
# -----------------------------
q14 = df[df['country'].str.contains('India', na=False) & df['casts'].notna()]
# Split actors
actors = q14['casts'].str.split(',', expand=True).stack().str.strip()
q14_result = actors.value_counts().reset_index().rename(columns={'index':'actor','casts':'appearances'}).head(10)
print(q14_result)

# -----------------------------
# 15. Categorize content as 'Good' or 'Bad' based on description
# -----------------------------
df['category_label'] = df['show_description'].str.lower().apply(
    lambda x: 'Bad' if ('kill' in str(x) or 'violence' in str(x)) else 'Good'
)
q15 = df.groupby(['category_label','show_type'])['show_id'].count().reset_index(name='content_count').sort_values('show_type')
print(q15)

# -----------------------------
# End of Netflix Project
# -----------------------------
