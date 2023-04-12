class X2DLCInfo_WOTCRandomGatecrasherLoadouts extends X2DownloadableContentInfo;

struct RandomLoadoutSlot
{
	var EInventorySlot 	Slot;
	var int 			Number;
	var array<name> 	Items;
	var array<name>		Upgrades;

	structdefaultproperties
	{
		Number = 1;
	}
};

struct RandomLoadout
{
	var name 						SoldierClass;
	var array<RandomLoadoutSlot> 	Slots;
};

struct GatecrasherLoadout
{
	var name 			SoldierClass;
	var array<name>		ArmorList;
	var array<name>		PrimaryWeaponList;
	var array<name>		SecondaryWeaponList;
	var array<name>		SidearmList;
	var array<name>		AModList;
	var array<name>		VestList;
	var array<name>		GrenadeList;
	var array<name>		AmmoList;
	var array<name>		MAWList;
	var array<name>		UtilityList;
	var int				UtilityNumber;
	var array<name>		WeaponUpgradeList;
	var array<name>		ArmorUpgradeList;
};

var config(GatecrasherLoadouts) bool								UseVersion2;
var config(GatecrasherLoadouts) array<GateCrasherLoadout>			GCLoadouts2;
var config(GatecrasherLoadouts) bool								UseVersion3;
var config(GatecrasherLoadouts) array<RandomLoadout>				GCLoadouts3;


static event InstallNewCampaign(XComGameState StartState)
{
	local XComGameState_HeadquartersXCom	 XComHQ;
	local StateObjectReference				 Ref;
	local XComGameState_Unit				 UnitState;
	local array<XComGameState_Unit>			 UnitStates;
	

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}
	if (XComHQ == none)
		return;

	//	## Build an array of Unit States of soldiers in squad.
	foreach XComHQ.Squad(Ref)
	{
		UnitState = XComGameState_Unit(StartState.GetGameStateForObjectID(Ref.ObjectID));
		if (UnitState != none)
		{
			UnitStates.AddItem(UnitState);
		}
	}
	if (UnitStates.Length == 0)
		return;
	if (default.UseVersion3)
		Version3(StartState, XComHQ, UnitStates);
	else if (default.UseVersion2)
		Version2(StartState, XComHQ, UnitStates);
}

static private function Version2(XComGameState StartState, XComGameState_HeadquartersXCom XComHQ, array<XComGameState_Unit> UnitStates)
{
	local X2ItemTemplateManager		ItemMgr;
	local XComGameState_Unit 		UnitState;
	local GateCrasherLoadout		Loadout;
	local array<name>				ValidArmor, ValidPrimaryWeapon, ValidSecondaryWeapon, ValidSidearm, ValidAMod, ValidVest, ValidGrenade, ValidAmmo, ValidUtility, ValidMAW, EmptyList;
	local int						i;

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	//	## Go through all units in the squad.
	foreach UnitStates(UnitState)
	{
		foreach default.GCLoadouts2(Loadout)
		{
			if (Loadout.SoldierClass != UnitState.GetSoldierClassTemplateName())
				continue;

			`Log("RGL: Soldier " $ UnitState.GetFullName() $ " | " $ Loadout.SoldierClass);
			ValidArmor = AreItemsValid(Loadout.ArmorList, ItemMgr);
			ValidPrimaryWeapon = AreItemsValid(Loadout.PrimaryWeaponList, ItemMgr);
			ValidSecondaryWeapon = AreItemsValid(Loadout.SecondaryWeaponList, ItemMgr);
			ValidSidearm = AreItemsValid(Loadout.SidearmList, ItemMgr);
			ValidVest = AreItemsValid(Loadout.VestList, ItemMgr);
			ValidGrenade = AreItemsValid(Loadout.GrenadeList, ItemMgr);
			ValidAmmo = AreItemsValid(Loadout.AmmoList, ItemMgr);
			ValidUtility = AreItemsValid(Loadout.UtilityList, ItemMgr);
			ValidAMod = AreItemsValid(Loadout.AModList, ItemMgr);
			ValidMAW = AreItemsValid(Loadout.MAWList, ItemMgr);
		
			if (ValidArmor.Length > 0)
				AddItemToLoadout(ValidArmor, eInvSlot_Armor, ItemMgr, UnitState, StartState, XComHQ, LoadOut.ArmorUpgradeList);
			if (ValidPrimaryWeapon.Length > 0)
				AddItemToLoadout(ValidPrimaryWeapon, eInvSlot_PrimaryWeapon, ItemMgr, UnitState, StartState, XComHQ, LoadOut.WeaponUpgradeList);
			if (ValidSecondaryWeapon.Length > 0)
				AddItemToLoadout(ValidSecondaryWeapon, eInvSlot_SecondaryWeapon, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidSidearm.Length > 0)
				AddItemToLoadout(ValidSidearm, eInvSlot_Pistol, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidVest.Length > 0)
				AddItemToLoadout(ValidVest, eInvSlot_Vest, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidAMod.Length > 0)
				AddItemToLoadout(ValidAMod, eInvSlot_ArmorMod, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidGrenade.Length > 0)
				AddItemToLoadout(ValidGrenade, eInvSlot_GrenadePocket, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidAmmo.Length > 0)
				AddItemToLoadout(ValidAmmo, eInvSlot_AmmoPocket, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidMAW.Length > 0)
				AddItemToLoadout(ValidMAW, eInvSlot_ViperMAW, ItemMgr, UnitState, StartState, XComHQ, EmptyList);
			if (ValidUtility.Length > 0)
			{
				for (i = 0; i < Loadout.UtilityNumber; i++)
				{
					AddItemToLoadout(ValidUtility, eInvSlot_Utility, ItemMgr, UnitState, StartState, XComHQ, EmptyList, i);
				}
			}
		}
		// One soldier handled. Go the to the next unit in squad.
	}
}

static private function Version3(XComGameState StartState, XComGameState_HeadquartersXCom XComHQ, array<XComGameState_Unit> UnitStates)
{
	local X2ItemTemplateManager		ItemMgr;
	local XComGameState_Unit 		UnitState;
	local RandomLoadout				Loadout;
	local RandomLoadoutSlot			Slot;
	local array<name>				ValidItems;
	local int						i;

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	//	## Go through all units in the squad.
	foreach UnitStates(UnitState)
	{
		foreach default.GCLoadouts3(Loadout)
		{
			if (Loadout.SoldierClass != UnitState.GetSoldierClassTemplateName())
				continue;

			`Log("RGL: Soldier " $ UnitState.GetFullName() $ " | " $ Loadout.SoldierClass);

			foreach Loadout.Slots(Slot)
			{
				ValidItems = AreItemsValid(Slot.Items, ItemMgr);

				if (ValidItems.Length > 0)
				{
					for (i = 0; i < Slot.Number; i++)
					{
						AddItemToLoadout(ValidItems, Slot.Slot, ItemMgr, UnitState, StartState, XComHQ, Slot.Upgrades, i);
					}
				}
			}
		}
		// One soldier handled. Go the to the next unit in squad.
	}
}

static private function array<name> AreItemsValid(const Array<Name> Items, const X2ItemTemplateManager ItemMgr)
{
	local Array<Name>	ValidItems;
	local Name			Item;
	
	foreach Items(Item)
	{
		if (X2EquipmentTemplate(ItemMgr.FindItemTemplate(Item)) != none)
			ValidItems.AddItem(Item);
	}

	return ValidItems;
}

static private function name GetRandomItem(const Array<name> Items)
{
	return Items[`SYNC_RAND_STATIC(Items.Length)];
}

static private function AddItemToLoadout(const array<Name> Items, EInventorySlot Slot, const X2ItemTemplateManager ItemMgr, ref XComGameState_Unit UnitState, XComGameState StartState, XComGameState_HeadquartersXCom XComHQ, array<name> Upgrades, optional int index = 0)
{
	local X2EquipmentTemplate				EqTemplate;
	local array<XComGameState_Item>			ItemStates;
	local XComGameState_Item				ItemState;
	local Name								Item, Upgrade;
	local bool								IsDistinct;
	local X2WeaponUpgradeTemplate 			WUTemplate;
	local array<name>						ValidUpgrades;

	IsDistinct = false;
	while (!IsDistinct)
	{
		IsDistinct = true;
		Item = GetRandomItem(Items);
		`Log("RGL: Checking " $ Item);
		if (Slot == eInvSlot_SecondaryWeapon)
		{
			ItemStates = UnitState.GetAllItemsInSlot(eInvSlot_PrimaryWeapon, StartState, true, true);
			foreach ItemStates(ItemState)
			{
				if (ItemState.GetMyTemplate().Name == Item)
					IsDistinct = false;
			}
		}
		else if (Slot == eInvSlot_Pistol)
		{
			ItemStates = UnitState.GetAllItemsInSlot(eInvSlot_PrimaryWeapon, StartState, true, true);
			foreach ItemStates(ItemState)
			{
				if (ItemState.GetMyTemplate().Name == Item)
					IsDistinct = false;
			}

			ItemStates = UnitState.GetAllItemsInSlot(eInvSlot_SecondaryWeapon, StartState, true, true);
			foreach ItemStates(ItemState)
			{
				if (ItemState.GetMyTemplate().Name == Item)
					IsDistinct = false;
			}
		}
	}

	//	Access equipment template of this item.
	EqTemplate = X2EquipmentTemplate(ItemMgr.FindItemTemplate(Item));

	//	Use the inventory slot in the equipment template if it was not specified in config.
	if (Slot == eInvSlot_Unknown)
	{
		Slot = EqTemplate.InventorySlot;
	}

	//	Remove already equipped item(s) in this slot.
	if (class'CHItemSlot'.static.SlotIsMultiItem(Slot))
	{
		// If we have not removed all items from this slot before, do this now.
		if (index == 0)
		{
			ItemStates = UnitState.GetAllItemsInSlot(Slot, StartState, true, true);
			foreach ItemStates(ItemState)
			{
				if (UnitState.RemoveItemFromInventory(ItemState, StartState))
				{
					XComHQ.PutItemInInventory(StartState, ItemState);
					`Log("RGL: Removing " $ ItemState.GetMyTemplateName() $ " to " $ Slot);
				}
				else
				{
					`LOG("WARNING, unable to remove item:" @ ItemState.GetMyTemplateName() @ "from inventory slot:" @ Slot @ "on soldier class:" @ UnitState.GetSoldierClassTemplateName(),, name(default.DLCIdentifier));
				}
			}
		}
	}
	else
	{
		ItemState = UnitState.GetItemInSlot(Slot, StartState, true);
		if (UnitState.RemoveItemFromInventory(ItemState, StartState))
		{
			XComHQ.PutItemInInventory(StartState, ItemState);
			`Log("RGL: Removing " $ ItemState.GetMyTemplateName() $ " to " $ Slot);
		}
		else
		{
			`LOG("WARNING, unable to remove item:" @ ItemState.GetMyTemplateName() @ "from inventory slot:" @ Slot @ "on soldier class:" @ UnitState.GetSoldierClassTemplateName(),, name(default.DLCIdentifier));
		}
	}
	
	ItemState = EqTemplate.CreateInstanceFromTemplate(StartState);
	foreach Upgrades(Upgrade)
	{
		`Log("RGL: Checking upgrade " $ Upgrade);

		if (Upgrade == '') 
		{
			ValidUpgrades.AddItem(Upgrade);
			continue;
		}
			
		WUTemplate = X2WeaponUpgradeTemplate(ItemMgr.FindItemTemplate(Upgrade));
		if (WUTemplate != none && WUTemplate.CanApplyUpgradeToWeapon(ItemState))
			ValidUpgrades.AddItem(Upgrade);	
	}

	if (ValidUpgrades.length > 0)
	{
		Upgrade = GetRandomItem(ValidUpgrades);
		`Log("RGL: Selected upgrade " $ Upgrade);

		// Equip item on the soldier. Delete the item if we fail.	
		if (Upgrade != '')
		{
			WUTemplate = X2WeaponUpgradeTemplate(ItemMgr.FindItemTemplate(Upgrade));
			ItemState.ApplyWeaponUpgradeTemplate(WUtemplate);
			`Log("RGL: Adding " $ WUTemplate.Name $ " to " $ ItemState.GetMyTemplateName());
		}
	}
	
	`Log("RGL: Adding " $ ItemState.GetMyTemplateName() $ " to " $ Slot);
	if (!UnitState.AddItemToInventory(ItemState, Slot, StartState))
	{		
		`LOG("WARNING, unable to add item:" @ ItemState.GetMyTemplateName() @ "to inventory slot:" @ Slot @ "on soldier class:" @ UnitState.GetSoldierClassTemplateName(),, name(default.DLCIdentifier));
		StartState.PurgeGameStateForObjectID(ItemState.ObjectID);
	}
	UnitState.ValidateLoadout(StartState);
}