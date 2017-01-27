module timeAccumulator;

import std.math;

struct TimeAccumulator
{
	void addTime(float delta)
	{
		++frameCount;
		totalTime += delta;
	}

	int averageRate()
	{
		return cast(int)nearbyint(1 / (totalTime / frameCount));
	}

	float trackedWindow()
	{
		return totalTime;
	}

	void reset()
	{
		frameCount = 0;
		totalTime = 0f;
	}

private:
	int frameCount;
	float totalTime = 0f;
}