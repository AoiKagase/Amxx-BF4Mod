#pragma semicolon 1
native check(value, code);
#include <bf4/progression_snapshot>
#include <bf4/progression_math>

public main()
{
	new record[StoreRecord];
	check(StoreDecode("2 32160000 7 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37", record), 1);
	check(record[SR_TOTAL_XP] == 32160000 && record[SR_REVISION] == 7, 2);
	check(record[SR_AWARD_COUNTS] == 0 && record[SR_AWARD_COUNTS + 18] == 18 && record[SR_AWARD_COUNTS + 19] == 19 &&
			  record[SR_AWARD_COUNTS + 37] == 37,
		  3);
	check(!StoreDecode("2 5 1 0", record), 4);
	check(record[SR_TOTAL_XP] == 32160000, 5); // Failed decode is atomic.
	check(!StoreDecode("3 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0", record), 6);
	check(!StoreDecode("2 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0", record), 7);
	check(!StoreDecode("2 2147483648 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0", record), 8);
	check(!StoreDecode("2 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 extra", record), 9);
	check(!StoreDecode("2 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 x", record), 10);
	record[SR_REVISION] = 9;
	record[SR_IS_SAVE_PENDING] = true;
	record[SR_HAS_UNSAVED_CHANGES] = true;
	StoreAcknowledge(record, 8, true);
	check(record[SR_HAS_UNSAVED_CHANGES] && !record[SR_IS_SAVE_PENDING], 11); // Newer in-flight mutation survives ACK.
	record[SR_IS_SAVE_PENDING] = true;
	StoreAcknowledge(record, 9, false);
	check(record[SR_HAS_UNSAVED_CHANGES] && !record[SR_IS_SAVE_PENDING], 12); // DB failure leaves retry work.
	StoreAcknowledge(record, 9, true);
	check(!record[SR_HAS_UNSAVED_CHANGES] && !record[SR_IS_SAVE_PENDING], 13);
	check(ProgressionClampXP(3000, 125) == 3125, 14);
	check(ProgressionClampXP(2147483640, 100) == 2147483647, 15);
	check(ProgressionClampXP(4, -7) == 0, 16);
	check(ProgressionClampXP(2147483647, -2147483647 - 1) == 0, 17);
	check(ProgressionClampXP(0, -1) == 0, 18);
	check(ProgressionClampXP(3000, -7) == 2993, 19);
	check(StoreParseImportRow("nick: Player Name ^t32160000^t0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37", record), 20);
	check(record[SR_PLAYER_KEY + 5] == ' ' && record[SR_PLAYER_KEY + 17] == ' ' &&
			  record[SR_PLAYER_KEY + 18] == 0,
		  21);
	check(record[SR_TOTAL_XP] == 32160000 && record[SR_AWARD_COUNTS + 37] == 37, 22);
	check(!StoreParseImportRow("nick:^t1^t0,0", record), 23);
	check(!StoreParseImportRow("STEAM_0:1:123^t1^t0,0", record), 24);
	check(!StoreParseImportRow("steam:STEAM_0:1:123^t1^t0,,0", record), 25);
	check(!StoreParseImportRow("nick:name^t1^t0,0,", record), 26);
	check(!StoreParseImportRow("nick:name^t-1^t0,0", record), 27);
	new binary[132];
	StoreSQLKey("nick:a\b'", binary, 131);
	check(binary[0] == '0' && binary[1] == 'x' &&
			  binary[2] == '6' && binary[3] == 'E',
		  28);
	check(binary[14] == '5' && binary[15] == 'C' &&
			  binary[18] == '2' && binary[19] == '7' && binary[20] == 0,
		  29);
	new invalid[10] = "nick:x";
	invalid[5] = 1;
	check(!SnapshotKeyValid(invalid), 30);
	invalid[5] = 192;
	invalid[6] = 128;
	invalid[7] = 0;
	check(!SnapshotKeyValid(invalid), 31);
	invalid[5] = 237;
	invalid[6] = 160;
	invalid[7] = 128;
	invalid[8] = 0;
	check(!SnapshotKeyValid(invalid), 32);
	invalid[5] = 227;
	invalid[6] = 129;
	invalid[7] = 130;
	check(SnapshotKeyValid(invalid), 33);
	record[SR_IS_LOADED] = false;
	record[SR_HAS_UNSAVED_CHANGES] = true;
	check(!StoreCanFlush(record), 34);
	record[SR_IS_LOADED] = true;
	record[SR_IS_SAVE_PENDING] = true;
	check(!StoreCanFlush(record), 35);
	record[SR_IS_SAVE_PENDING] = false;
	record[SR_HAS_UNSAVED_CHANGES] = false;
	check(!StoreCanFlush(record), 36);
	record[SR_HAS_UNSAVED_CHANGES] = true;
	check(StoreCanFlush(record), 37);
	return 37;
}
