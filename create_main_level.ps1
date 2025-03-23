$sceneContent = @'
[gd_scene load_steps=9 format=3 uid="uid://cn7gcev7wi1lx"]

[ext_resource type="Texture2D" uid="uid://c5mhpm0kbgy7x" path="res://Assets/Tilepacks/Textures-16.png" id="1_glv2v"]
[ext_resource type="PackedScene" uid="uid://d25rsiobsvetv" path="res://parallaxbackground.tscn" id="2_uu6xs"]
[ext_resource type="PackedScene" path="res://scenes/Player.tscn" id="3_ybg3g"]
[ext_resource type="PackedScene" uid="uid://dckpjtfpxjvhc" path="res://scenes/enemies/Enemy1.tscn" id="4_dthrx"]
[ext_resource type="PackedScene" uid="uid://bd4v5hc6ibdda" path="res://scenes/enemies/Enemy2.tscn" id="5_xsnwr"]
[ext_resource type="PackedScene" uid="uid://b1g3jbpgq8vyu" path="res://scenes/enemies/Enemy3.tscn" id="6_wl8h2"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_uu6xs"]
texture = ExtResource("1_glv2v")
0:0/0 = 0
0:0/0/physics_layer_0/linear_velocity = Vector2(0, 0)
0:0/0/physics_layer_0/angular_velocity = 0.0
1:0/0 = 0
1:0/0/physics_layer_0/linear_velocity = Vector2(0, 0)
1:0/0/physics_layer_0/angular_velocity = 0.0
2:0/0 = 0
2:0/0/physics_layer_0/linear_velocity = Vector2(0, 0)
2:0/0/physics_layer_0/angular_velocity = 0.0
3:0/0 = 0
3:0/0/physics_layer_0/linear_velocity = Vector2(0, 0)
3:0/0/physics_layer_0/angular_velocity = 0.0
0:2/0 = 0
0:2/0/physics_layer_0/linear_velocity = Vector2(0, 0)
0:2/0/physics_layer_0/angular_velocity = 0.0
0:2/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
1:2/0 = 0
1:2/0/physics_layer_0/linear_velocity = Vector2(0, 0)
1:2/0/physics_layer_0/angular_velocity = 0.0
1:2/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
2:2/0 = 0
2:2/0/physics_layer_0/linear_velocity = Vector2(0, 0)
2:2/0/physics_layer_0/angular_velocity = 0.0
2:2/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
3:2/0 = 0
3:2/0/physics_layer_0/linear_velocity = Vector2(0, 0)
3:2/0/physics_layer_0/angular_velocity = 0.0
3:2/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)

[sub_resource type="TileSet" id="TileSet_r0du0"]
physics_layer_0/collision_layer = 1
sources/0 = SubResource("TileSetAtlasSource_uu6xs")

[node name="Main" type="Node2D"]

[node name="ParallaxBackground" parent="." instance=ExtResource("2_uu6xs")]

[node name="TileMap" type="TileMap" parent="."]
tile_set = SubResource("TileSet_r0du0")
format = 2
layer_0/name = "Ground"

[node name="Player" parent="." instance=ExtResource("3_ybg3g")]
position = Vector2(100, 300)

[node name="Enemies" type="Node2D" parent="."]

[node name="Enemy1" parent="Enemies" instance=ExtResource("4_dthrx")]
position = Vector2(400, 300)
patrol_points = [NodePath("../../PatrolPoints/Point1"), NodePath("../../PatrolPoints/Point2")]

[node name="Enemy2" parent="Enemies" instance=ExtResource("5_xsnwr")]
position = Vector2(600, 300)
patrol_points = [NodePath("../../PatrolPoints/Point3"), NodePath("../../PatrolPoints/Point4")]

[node name="Enemy3" parent="Enemies" instance=ExtResource("6_wl8h2")]
position = Vector2(800, 300)
patrol_points = [NodePath("../../PatrolPoints/Point5"), NodePath("../../PatrolPoints/Point6")]

[node name="PatrolPoints" type="Node2D" parent="."]

[node name="Point1" type="Marker2D" parent="PatrolPoints"]
position = Vector2(300, 300)

[node name="Point2" type="Marker2D" parent="PatrolPoints"]
position = Vector2(500, 300)

[node name="Point3" type="Marker2D" parent="PatrolPoints"]
position = Vector2(500, 300)

[node name="Point4" type="Marker2D" parent="PatrolPoints"]
position = Vector2(700, 300)

[node name="Point5" type="Marker2D" parent="PatrolPoints"]
position = Vector2(700, 300)

[node name="Point6" type="Marker2D" parent="PatrolPoints"]
position = Vector2(900, 300)
'@

Set-Content -Path "MainLevel.tscn" -Value $sceneContent

Write-Output "Created MainLevel.tscn - import this scene in Godot" 