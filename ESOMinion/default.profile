-- Persistent Data
local multiRefObjects = {

} -- multiRefObjects
local obj1 = {
	["itemtypes"] = {
		[1] = {
			["id"] = 1;
			["show"] = true;
			["name"] = "ITEMTYPE_WEAPON";
			["label"] = "Weapon";
		};
		[2] = {
			["id"] = 2;
			["show"] = true;
			["name"] = "ITEMTYPE_ARMOR";
			["label"] = "Armor";
		};
		[3] = {
			["id"] = 3;
			["show"] = false;
			["name"] = "ITEMTYPE_PLUG";
			["label"] = "Plug";
		};
		[4] = {
			["id"] = 4;
			["show"] = true;
			["name"] = "ITEMTYPE_FOOD";
			["label"] = "Food";
		};
		[5] = {
			["id"] = 5;
			["show"] = true;
			["name"] = "ITEMTYPE_TROPHY";
			["label"] = "Trophy";
		};
		[6] = {
			["id"] = 6;
			["show"] = false;
			["name"] = "ITEMTYPE_SIEGE";
			["label"] = "Siege";
		};
		[7] = {
			["id"] = 7;
			["show"] = true;
			["name"] = "ITEMTYPE_POTION";
			["label"] = "Potion";
		};
		[8] = {
			["id"] = 8;
			["show"] = false;
			["name"] = "ITEMTYPE_RACIAL_STYLE_MOTIF";
			["label"] = "RacialStyleMotif";
		};
		[9] = {
			["id"] = 9;
			["show"] = false;
			["name"] = "ITEMTYPE_TOOL";
			["label"] = "Tool";
		};
		[10] = {
			["id"] = 10;
			["show"] = true;
			["name"] = "ITEMTYPE_INGREDIENT";
			["label"] = "Ingredient";
		};
		[11] = {
			["id"] = 11;
			["show"] = false;
			["name"] = "ITEMTYPE_ADDITIVE";
			["label"] = "Additive";
		};
		[12] = {
			["id"] = 12;
			["show"] = true;
			["name"] = "ITEMTYPE_DRINK";
			["label"] = "Drink";
		};
		[13] = {
			["id"] = 13;
			["show"] = true;
			["name"] = "ITEMTYPE_COSTUME";
			["label"] = "Costume";
		};
		[14] = {
			["id"] = 14;
			["show"] = true;
			["name"] = "ITEMTYPE_DISGUISE";
			["label"] = "Disguise";
		};
		[15] = {
			["id"] = 15;
			["show"] = false;
			["name"] = "ITEMTYPE_TABARD";
			["label"] = "Tabard";
		};
		[16] = {
			["id"] = 16;
			["show"] = true;
			["name"] = "ITEMTYPE_LURE";
			["label"] = "Lure";
		};
		[17] = {
			["id"] = 17;
			["show"] = true;
			["name"] = "ITEMTYPE_RAW_MATERIAL";
			["label"] = "RawMaterial";
		};
		[18] = {
			["id"] = 18;
			["show"] = true;
			["name"] = "ITEMTYPE_CONTAINER";
			["label"] = "Container";
		};
		[19] = {
			["id"] = 19;
			["show"] = false;
			["name"] = "ITEMTYPE_SOUL_GEM";
			["label"] = "SoulGem";
		};
		[20] = {
			["id"] = 20;
			["show"] = true;
			["name"] = "ITEMTYPE_GLYPH_WEAPON";
			["label"] = "GlyphWeapon";
		};
		[21] = {
			["id"] = 21;
			["show"] = true;
			["name"] = "ITEMTYPE_GLYPH_ARMOR";
			["label"] = "GlyphArmor";
		};
		[22] = {
			["id"] = 22;
			["show"] = false;
			["name"] = "ITEMTYPE_LOCKPICK";
			["label"] = "Lockpick";
		};
		[23] = {
			["id"] = 23;
			["show"] = false;
			["name"] = "ITEMTYPE_WEAPON_BOOSTER";
			["label"] = "WeaponBooster";
		};
		[24] = {
			["id"] = 24;
			["show"] = false;
			["name"] = "ITEMTYPE_ARMOR_BOOSTER";
			["label"] = "ArmorBooster";
		};
		[25] = {
			["id"] = 25;
			["show"] = false;
			["name"] = "ITEMTYPE_ENCHANTMENT_BOOSTER";
			["label"] = "EnchantmentBooster";
		};
		[26] = {
			["id"] = 26;
			["show"] = true;
			["name"] = "ITEMTYPE_GLYPH_JEWELRY";
			["label"] = "GlyphJewelry";
		};
		[27] = {
			["id"] = 27;
			["show"] = false;
			["name"] = "ITEMTYPE_SPICE";
			["label"] = "Spice";
		};
		[28] = {
			["id"] = 28;
			["show"] = false;
			["name"] = "ITEMTYPE_FLAVORING";
			["label"] = "Flavoring";
		};
		[29] = {
			["id"] = 29;
			["show"] = true;
			["name"] = "ITEMTYPE_RECIPE";
			["label"] = "Recipe";
		};
		[30] = {
			["id"] = 30;
			["show"] = false;
			["name"] = "ITEMTYPE_POISON";
			["label"] = "Poison";
		};
		[31] = {
			["id"] = 31;
			["show"] = true;
			["name"] = "ITEMTYPE_REAGENT";
			["label"] = "Reagent";
		};
		[32] = {
			["id"] = 32;
			["show"] = false;
			["name"] = "ITEMTYPE_DEPRECATED";
			["label"] = "Deprecated";
		};
		[33] = {
			["id"] = 33;
			["show"] = true;
			["name"] = "ITEMTYPE_ALCHEMY_BASE";
			["label"] = "AlchemyBase";
		};
		[34] = {
			["id"] = 34;
			["show"] = true;
			["name"] = "ITEMTYPE_COLLECTIBLE";
			["label"] = "Collectible";
		};
		[35] = {
			["id"] = 35;
			["show"] = true;
			["name"] = "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL";
			["label"] = "BlacksmithingRawMaterial";
		};
		[36] = {
			["id"] = 36;
			["show"] = true;
			["name"] = "ITEMTYPE_BLACKSMITHING_MATERIAL";
			["label"] = "BlacksmithingMaterial";
		};
		[37] = {
			["id"] = 37;
			["show"] = true;
			["name"] = "ITEMTYPE_WOODWORKING_RAW_MATERIAL";
			["label"] = "WoodworkingRawMaterial";
		};
		[38] = {
			["id"] = 38;
			["show"] = true;
			["name"] = "ITEMTYPE_WOODWORKING_MATERIAL";
			["label"] = "WoodworkingMaterial";
		};
		[39] = {
			["id"] = 39;
			["show"] = true;
			["name"] = "ITEMTYPE_CLOTHIER_RAW_MATERIAL";
			["label"] = "ClothierRawMaterial";
		};
		[40] = {
			["id"] = 40;
			["show"] = true;
			["name"] = "ITEMTYPE_CLOTHIER_MATERIAL";
			["label"] = "ClothierMaterial";
		};
		[41] = {
			["id"] = 41;
			["show"] = false;
			["name"] = "ITEMTYPE_BLACKSMITHING_BOOSTER";
			["label"] = "BlacksmithingBooster";
		};
		[42] = {
			["id"] = 42;
			["show"] = false;
			["name"] = "ITEMTYPE_WOODWORKING_BOOSTER";
			["label"] = "WoodworkingBooster";
		};
		[43] = {
			["id"] = 43;
			["show"] = false;
			["name"] = "ITEMTYPE_CLOTHIER_BOOSTER";
			["label"] = "ClothierBooster";
		};
		[44] = {
			["id"] = 44;
			["show"] = true;
			["name"] = "ITEMTYPE_STYLE_MATERIAL";
			["label"] = "StyleMaterial";
		};
		[45] = {
			["id"] = 45;
			["show"] = true;
			["name"] = "ITEMTYPE_ARMOR_TRAIT";
			["label"] = "ArmorTrait";
		};
		[46] = {
			["id"] = 46;
			["show"] = true;
			["name"] = "ITEMTYPE_WEAPON_TRAIT";
			["label"] = "WeaponTrait";
		};
		[47] = {
			["id"] = 47;
			["show"] = false;
			["name"] = "ITEMTYPE_AVA_REPAIR";
			["label"] = "AvaRepair";
		};
		[48] = {
			["id"] = 48;
			["show"] = false;
			["name"] = "ITEMTYPE_TRASH";
			["label"] = "Trash";
		};
		[49] = {
			["id"] = 49;
			["show"] = false;
			["name"] = "ITEMTYPE_SPELLCRAFTING_TABLET";
			["label"] = "SpellcraftingTablet";
		};
		[50] = {
			["id"] = 50;
			["show"] = false;
			["name"] = "ITEMTYPE_MOUNT";
			["label"] = "Mount";
		};
		[51] = {
			["id"] = 51;
			["show"] = true;
			["name"] = "ITEMTYPE_ENCHANTING_RUNE_POTENCY";
			["label"] = "RunePotency";
		};
		[52] = {
			["id"] = 52;
			["show"] = true;
			["name"] = "ITEMTYPE_ENCHANTING_RUNE_ASPECT";
			["label"] = "RuneAspect";
		};
		[53] = {
			["id"] = 53;
			["show"] = true;
			["name"] = "ITEMTYPE_ENCHANTING_RUNE_ESSENCE";
			["label"] = "RuneEssence";
		};
	};
	["data"] = {
		[1] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[2] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[3] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[4] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[5] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[6] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[7] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[8] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[9] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[10] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[11] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[12] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[13] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[14] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[15] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[16] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[17] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[18] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[19] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[20] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[21] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[22] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[23] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[24] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[25] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[26] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[27] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[28] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[29] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[30] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[31] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[32] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[33] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[34] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[35] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[36] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[37] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[38] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[39] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[40] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[41] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[42] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[43] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[44] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[45] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[46] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[47] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[48] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[49] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[50] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[51] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[52] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
		[53] = {
			[1] = false;
			[2] = false;
			[3] = false;
			[4] = false;
			[5] = false;
		};
	};
	["qualities"] = {
		[1] = {
			["id"] = 1;
			["show"] = true;
			["name"] = "ITEM_QUALITY_NORMAL";
			["label"] = "Normal";
		};
		[2] = {
			["id"] = 2;
			["show"] = true;
			["name"] = "ITEM_QUALITY_MAGIC";
			["label"] = "Magic";
		};
		[3] = {
			["id"] = 3;
			["show"] = true;
			["name"] = "ITEM_QUALITY_ARCANE";
			["label"] = "Arcane";
		};
		[4] = {
			["id"] = 4;
			["show"] = true;
			["name"] = "ITEM_QUALITY_ARTIFACT";
			["label"] = "Artifact";
		};
		[5] = {
			["id"] = 5;
			["show"] = false;
			["name"] = "ITEM_QUALITY_LEGENDARY";
			["label"] = "Legendary";
		};
	};
}
return obj1
