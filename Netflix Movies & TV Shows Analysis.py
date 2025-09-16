# Netflix Movies & TV Shows Analysis Project

# Commencement of thr project
import pandas as pd
from datetime import timedelta

# Step 1 - Load Data
df = pd.read_csv("netflix.csv", encoding_errors='ignore')

# Basic cleaning
df.drop_duplicates(inplace=True)
df.dropna(subset=['show_id'], inplace=True)
df['date_added'] = pd.to_datetime(df['date_added'], errors='coerce')

# 1. Count the number of Movies and TV Shows
q1 = df.groupby('show_type')['show_id'].count().reset_index(name='total').sort_values('total')
print(q1)

# 2. Most common rating for movies and TV shows
q2 = df.groupby(['show_type','rating']).size().reset_index(name='rating_count')
q2['rank'] = q2.groupby('show_type')['rating_count'].rank(ascending=False, method='dense')
q2 = q2[q2['rank']==1].sort_values('show_type')
print(q2[['show_type','rating','rating_count']])

# 3. Movies released in 2020
q3 = df[(df['show_type']=='Movie') & (df['release_year']==2020)]
print(q3)

# 4. Top 5 countries with most content
df['primary_country'] = df['country'].str.split(',', expand=True)[0].str.strip()
q4 = df[df['primary_country'].notna() & (df['primary_country'] != '')] \
        .groupby('primary_country')['show_id'].count() \
        .reset_index(name='total_content') \
        .sort_values('total_content', ascending=False).head(5)
print(q4)

# 5. Identify the 5 longest movies
df['duration_num'] = df['duration'].str.extract('(\d+)').astype(float)
q5 = df[df['show_type']=='Movie'].sort_values('duration_num', ascending=False).head(5)
print(q5)

# 6. Content added in last 5 years
five_years_ago = pd.Timestamp.today() - pd.DateOffset(years=5)
q6 = df[df['date_added'] >= five_years_ago]
print(q6)

# 7. Movies/TV shows by Steven Spielberg
q7 = df[df['director'].str.contains('Steven Spielberg', na=False)]
print(q7)

# 8. TV shows with more than 5 seasons
q8 = df[(df['show_type']=='TV Show') & (df['duration_num']>5)]
print(q8)

# 9. Number of content items in each genre
df['genre_list'] = df['genre'].dropna().str.split(',').apply(lambda x: [g.strip() for g in x] if isinstance(x, list) else [])
genre_exploded = df.explode('genre_list')
q9 = genre_exploded.groupby('genre_list')['show_id'].nunique().reset_index(name='total_titles') \
      .sort_values('total_titles', ascending=False)
print(q9)

# 10. Top 5 years with highest content released by India (as %)
df_india = df[df['country'].str.contains('India', na=False)]
total_india = len(df_india)
q10 = df_india.groupby('release_year')['show_id'].count().reset_index(name='total_release')
q10['release_percentage'] = round(q10['total_release']/total_india*100, 2)
q10 = q10.sort_values('release_percentage', ascending=False).head(5)
print(q10)

# 11. List all documentaries
q11 = df[df['genre'].str.contains('Documentaries', na=False)]
print(q11)

# 12. Find all content without a director
q12 = df[df['director'].isna() | (df['director']=='')]
print(q12)

# 13. Movies with Salman Khan in last 10 years
current_year = pd.Timestamp.today().year
q13 = df[df['casts'].str.contains('Salman Khan', na=False) & (df['release_year'] > current_year-10)]
print(q13)

# 14. Top 10 actors in Indian content
df_india_casts = df_india[df_india['casts'].notna()]
df_india_casts['actor_list'] = df_india_casts['casts'].str.split(',').apply(lambda x: [a.strip() for a in x])
actors_exploded = df_india_casts.explode('actor_list')
q14 = actors_exploded['actor_list'].value_counts().reset_index()
q14.columns = ['actor','appearances']
q14 = q14.head(10)
print(q14)

# 15. Categorize content as 'Good' or 'Bad'
df['category_label'] = df['show_description'].str.lower().apply(
    lambda x: 'Bad' if ('kill' in str(x) or 'violence' in str(x)) else 'Good'
)
q15 = df.groupby(['category_label','show_type'])['show_id'].count().reset_index(name='content_count') \
         .sort_values('show_type')
print(q15)


# End of the Project

