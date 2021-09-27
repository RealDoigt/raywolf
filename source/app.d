import std.stdio;
import std.math;
import raylib;

struct Ray2d { Vector2 position, direction; }

double getDeltaDistance(double direction) { return direction == 0 ? double.infinity : abs(1 / direction); }
double getWallDistance(double map, float position, int step, double direction) { return (map - position + ((1 - step) >> 1)) / direction; }
void main()
{
	const int WINDOW_WIDTH = 640, WINDOW_HEIGHT = 480, MAP_WIDTH = 24, MAP_HEIGHT = 24;

	SetTargetFPS(60);
	InitWindow(WINDOW_HEIGHT, WINDOW_WIDTH, "Raycaster");

	Vector2 position = { 22, 12 };
	Vector2 plane = { 0, .66 };
	Vector2 direction = { -1, 0 };

	byte[MAP_WIDTH][MAP_HEIGHT] map =
	[
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
		[1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1],
		[1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ];

	while (!WindowShouldClose())
	{
		BeginDrawing();
		scope(exit) EndDrawing();

		for (int x = 0; x < WINDOW_WIDTH; ++x)
		{
			double cameraX = (x << 1) / WINDOW_WIDTH - 1;
			double rayDirX = direction.x + plane.x * cameraX;
			double rayDirY = direction.y + plane.y * cameraX;

			int mapX = cast(int)position.x, mapY = cast(int)position.y;
			double sideDistanceX, sideDistanceY;

			auto deltaDistanceX = getDeltaDistance(direction.x);
			auto deltaDistanceY = getDeltaDistance(direction.y);
			double wallDistance;

			int stepX, stepY, hit, side;

			if (rayDirX < 0)
			{
				stepX = -1;
				sideDistanceX = (position.x - mapX) * deltaDistanceX;
			}

			else
			{
				stepX = 1;
				sideDistanceX = (mapX + 1 - position.x) * deltaDistanceX;
			}

			if (rayDirY < 0)
			{
				stepY = -1;
				sideDistanceY = (position.y - mapY) * deltaDistanceY;
			}

			else
			{
				stepY = 1;
				sideDistanceY = (mapY + 1 - position.y) * deltaDistanceY;
			}

			while (!hit)
			{
				if (sideDistanceX < sideDistanceY)
				{
					sideDistanceX += deltaDistanceX;
					mapX += stepX;
					side = 0;
				}

				else
				{
					sideDistanceY += deltaDistanceY;
					mapY += stepY;
					side = 1;
				}

				if (map[mapY][mapX] > 0) hit = 1;
			}

			if (!side) wallDistance = getWallDistance(mapX, position.x, stepX, rayDirX);
			else wallDistance = getWallDistance(mapY, position.y, stepY, rayDirY);

			int lineHeight = cast(int)(WINDOW_HEIGHT / wallDistance);

			int drawStart = -(lineHeight >> 1) + (WINDOW_HEIGHT >> 1);
			if (drawStart < 0) drawStart = 0;

			int drawEnd = (lineHeight >> 1) + (WINDOW_HEIGHT >> 1);
			if (drawEnd >= WINDOW_HEIGHT) drawEnd = WINDOW_HEIGHT - 1;

			Color color;

			switch (map[mapY][mapX])
			{
				case 1:
					color = Colors.RED;
					break; // red

				case 2:
					color = Colors.GREEN;
					break; // green

				case 3:
					color = Colors.BLUE;
					break; // blue

				case 4:
					color = Colors.WHITE;
					break; // white

				default:
					color = Colors.YELLOW;
					break; // yellow
			}

			if (side) color.a = cast(ubyte)(color.a >> 1); // cheese to make the colour darker

			DrawLine(x, drawStart, x, drawEnd, color); // draw a vertical line
		}

		auto frameTime = GetFrameTime();

		DrawFPS(0, 0);

		auto moveSpeed = frameTime * 5;
		auto rotationSpeed = frameTime * 3;

		if (IsKeyDown(KeyboardKey.KEY_W))
		{
			if (!map[cast(int)position.y][cast(int)(position.x + direction.x * moveSpeed)])
				position.x += direction.x * moveSpeed;

			if (!map[cast(int)(position.y + direction.y * moveSpeed)][cast(int)(position.x)])
				position.y += direction.y * moveSpeed;
		}

		if (IsKeyDown(KeyboardKey.KEY_S))
		{
			if (!map[cast(int)position.y][cast(int)(position.x - direction.x * moveSpeed)])
				position.x -= direction.x * moveSpeed;

			if (!map[cast(int)(position.y - direction.y * moveSpeed)][cast(int)(position.x)])
				position.y -= direction.y * moveSpeed;
		}

		if (IsKeyDown(KeyboardKey.KEY_RIGHT))
		{
			double oldDirection = direction.x;
			direction.x = direction.x * cos(-rotationSpeed) - direction.y * sin(-rotationSpeed);
			direction.y = oldDirection * sin(-rotationSpeed) + direction.y * cos(-rotationSpeed);

			double oldPlane = plane.x;
			plane.x = plane.x * cos(-rotationSpeed) - plane.y * sin(-rotationSpeed);
			plane.y = oldPlane * sin(-rotationSpeed) + plane.y * cos(-rotationSpeed);
		}

		if (IsKeyDown(KeyboardKey.KEY_LEFT))
		{
			double oldDirection = direction.x;
			direction.x = direction.x * cos(rotationSpeed) - direction.y * sin(rotationSpeed);
			direction.y = oldDirection * sin(rotationSpeed) + direction.y * cos(rotationSpeed);

			double oldPlane = plane.x;
			plane.x = plane.x * cos(rotationSpeed) - plane.y * sin(rotationSpeed);
			plane.y = oldPlane * sin(rotationSpeed) + plane.y * cos(rotationSpeed);
		}

		ClearBackground(Colors.BLACK);
	}
}
