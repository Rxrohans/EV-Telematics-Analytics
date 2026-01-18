import pandas as pd
from sklearn.cluster import KMeans

# Load CSV
df = pd.read_csv('F:/turno/vehicle_locations.csv')

# Drop rows with missing lat/long
df_clean = df.dropna(subset=['avg_lat', 'avg_long']).copy()

# Filter invalid coordinates
df_clean = df_clean[
    (df_clean['avg_lat'] >= -90) & (df_clean['avg_lat'] <= 90) &
    (df_clean['avg_long'] >= -180) & (df_clean['avg_long'] <= 180)
]

# Run KMeans clustering
kmeans = KMeans(n_clusters=5, random_state=42)
df_clean['cluster'] = kmeans.fit_predict(df_clean[['avg_lat', 'avg_long']])

#Get actual cluster centers from KMeans
centers = pd.DataFrame(kmeans.cluster_centers_, columns=['center_lat', 'center_long'])
centers['cluster'] = centers.index

#  Get unique vehicle count per cluster
vehicle_counts = df_clean.groupby('cluster')['vin'].nunique().reset_index(name='vehicle_count')

# Merge cluster centers with vehicle counts
cluster_summary = pd.merge(vehicle_counts, centers, on='cluster')

# Save to CSV
cluster_summary.to_csv('F:/turno/question4.csv', index=False)

print(" clusters saved to csv file")
