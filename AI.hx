// ai class

class AI extends Player
{
  public function new(gvar, uivar, id, infoID)
    {
      super(gvar, uivar, id, infoID);
      isAI = true;
    }


// ai entry point
  function aiTurn()
    {
      // try to upgrade followers
      aiUpgradeFollowers();

      // try to lower awareness
      aiLowerAwareness();

      // try to summon
      aiSummon();

      // TODO: point-based weighted prioritization raises some thoughts
      // about current AI
      // "mood". Is it in an aggressive mood? +1 for any owned node
      // Is it in a war rage? +1 for any enemy node
      // give/take a point for each node attribute, storing the result

      // loop over visible nodes making a target list with priority
      var list = new Array<Dynamic>();
      for (node in game.nodes)
        {
          if (node.owner == this || !node.isVisible(this))
            continue;

          var item = { node: node, priority: 0 };

          // free node
          if (node.owner == null)
            item.priority++;

          // enemy node
          if (node.owner != null && wars[node.owner.id])
            item.priority++;
          // owned node
          else if (node.owner != null)
            item.priority--;

          // unprotected generators are always yummy
          if (node.isGenerator && !node.isProtected)
            item.priority += 2;

          // can activate it
          if (canActivate(node))
            item.priority++;

          list.push(item);
        }

      // sort target list by priority descending
      list.sort(function(x, y) {
        if (x.priority == y.priority)
          return 0;
        else if (x.priority > y.priority)
          return -1;
        else return 1;
        });

//      for (l in list)
//        trace(id + " " + l.priority + " " + l.node.id);

      // loop over target list activating it one by one
      for (item in list)
        {
          var node = item.node;

          // try to activate and get result
          var ret = activate(node);
          if (ret == "ok")
            continue;

          // check if player can convert resources for a try
          if (ret == "notEnoughPower")
            aiActivateNodeByConvert(node);

          // node is a generator with links, should try to cut them
          else if (ret == "hasLinks")
            1;
        }
    }


// try to upgrade followers
  function aiUpgradeFollowers()
    {
      if (virgins == 0)
        return;

      // aim for 5 adepts, try only when chance > 70%
      if (adepts < 5 && getUpgradeChance(0) > 70 && virgins > 0)
        {
//          if (Game.debugAI)
//            trace(name + " virgins: " + virgins);
          // spend all virgins on upgrades
          while (true)
            {
              if (virgins < 1 || adepts >= 5)
                break;
              upgrade(0);

              if (Game.debugAI)
                trace(name + " upgrade neophyte, adepts: " + adepts);
            }
          return;
        }

      // aim for 3 priests, try only when chance > 60%
      if (priests < 3 && getUpgradeChance(1) > 60 && virgins > 1)
        {
          // spend all virgins on upgrades
          while (true)
            {
              if (virgins < 2 || priests >= 3)
                break;
              upgrade(1);

              if (Game.debugAI)
                trace("!!! " + name + " upgrade adept, priests: " + priests);
            }
          return;
        }
    }


// try to lower awareness
  function aiLowerAwareness()
    {
      if (awareness < 10 || adepts == 0)
        return;
  
      var prevAwareness = awareness;

      // spend all we have
      for (i in 0...Game.numPowers)
        while (power[i] > 0 && adeptsUsed < adepts && awareness >= 10)
          lowerAwareness(i);

      if (Game.debugAI && awareness != prevAwareness)
        trace(name + " awareness " + prevAwareness + "% -> " + awareness + "%");
    }


// try to summon elder god
  public function aiSummon()
    {
      if (priests < 3 || virgins < 9 || getUpgradeChance(2) < 60 || isRitual)
        return;

      if (Game.debugAI)
        trace(name + " TRY SUMMON!");

      summonStart();
    }


// try to activate node by converting resources
  public function aiActivateNodeByConvert(node: Node)
    {
      // check for resources (1 res max assumed)
      var resNeed = -1;
	  for (i in 0...Game.numPowers)
		if (power[i] < node.power[i])
          resNeed = i;

      // check if we can convert resources
      // resources are not pooled and virgins are not spent
      var resConv = -1;
      for (i in 0...Game.numPowers)
        if (i != resNeed)
          if (Std.int(power[i] / Game.powerConversionCost[i]) >
              node.power[resNeed])
            resConv = i;

      // no suitable resource found
      if (resConv < 0)
        return;

      for (i in 0...node.power[resNeed])
        convert(resConv, resNeed);

      activate(node);
    }
}
