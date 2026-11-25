// Pawn cells are signed 32-bit. Check before addition, never after overflow.
stock ProgressionClampXP(current, amount)
{
	if (amount > 0 && current > 2147483647 - amount)
		return 2147483647;
	if (amount < 0 && amount < -current)
		return 0;
	return current + amount;
}
