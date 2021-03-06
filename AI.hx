// ai class

class AI extends Cult
{
  public function new(gvar, uivar, id, infoID)
    {
      super(gvar, uivar, id, infoID);
      isAI = true;

      // AI difficulty is the opposite of player difficulty
      if (game.difficultyLevel == 0)
        difficulty = Static.difficulty[2];
      else if (game.difficultyLevel == 2)
        difficulty = Static.difficulty[0];
      else
        difficulty = Static.difficulty[1];
    }


// ai entry point
  function aiTurn()
    {
      // cult is paralyzed and has investigator, it's dead but doesn't know it yet
      if (isParalyzed && hasInvestigator)
        {
          // try to lower awareness even using virgins
          aiLowerAwarenessHard();

          // if has investigator, he becomes the first priority
          aiLowerWillpower();

          return;
        }

      // cult is paralyzed - try upgrading
      if (isParalyzed)
        {
          // if has investigator, he becomes the first priority
          aiLowerWillpower();

          // try to upgrade followers
          aiUpgradeFollowers();

          return;
        }

      // has investigator
      if (hasInvestigator && adepts > 0)
        {
          // try to lower awareness even using virgins
          if (awareness >= difficulty.maxAwareness)
            aiLowerAwarenessHard();

          // try to destroy investigator
          else aiLowerWillpower();

          return;
        }

      // if has investigator, he becomes the first priority
//      aiLowerWillpower();

      // try to upgrade followers
      aiUpgradeFollowers();

      // if in summoning, try to lower awareness even using virgins
      if (isRitual && ritual.id == "summoning")
        aiLowerAwarenessHard();

      // try to lower awareness (without using virgins)
      aiLowerAwareness();

      // try to summon
      aiSummon();

      // if awareness is too high, stop here
      if (awareness > difficulty.maxAwareness && adepts > 0)
        return;

      // TODO: point-based weighted prioritization raises some thoughts
      // about current AI
      // "mood". Is it in an aggressive mood? +1 for any owned node
      // Is it in a war rage? +1 for any enemy node
      // give/take a point for each node attribute, storing the result

      // loop over visible nodes making a target list with priority
      var list = new Array<Dynamic>();
      for (node in game.nodes)
        {
          if (node.owner == this || !node.isVisible(this) ||
              (node.owner != null && node.owner.isDebugInvisible))
            continue;

          var item = { node: node, priority: 0 };

          // priests are first priority when they are performing the final ritual
          if (node.owner != null && node.level == 2 &&
              node.owner.isRitual && node.owner.ritual.id == "summoning")
            item.priority += 3;

          // free node
          if (node.owner == null)
            item.priority++;

          // enemy node
          if (node.owner != null && wars[node.owner.id])
            item.priority++;

          // enemy node + enemy is in final ritual
          else if (node.owner != null &&
                   node.owner.isRitual && node.owner.ritual.id == "summoning")
            item.priority += 2;

          // owned node
          else if (node.owner != null)
            item.priority--;

          // lower priority more when having investigator
          if (node.owner != null && hasInvestigator)
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

      // during the final ritual AIs will try to make peace
      aiTryPeace();
    }


// try to make peace with any not in ritual cults
  function aiTryPeace()
    {
      if (isRitual) return;

      // check if any cult is in ritual
      var ok = false;
      for (c in game.cults)
        if (c.isRitual)
          {
            ok = true;
            break;
          }
      // noone is casting ritual, no peace
      if (!ok) return;

      for (i in 0...3)
        if (wars[i] && !game.cults[i].isRitual)
          {
            // 30% chance of success
            if (Math.random() * 100 > 30)
              continue;

            makePeace(game.cults[i]);
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
              if (!canUpgrade(0) || virgins < 1 || adepts >= 5)
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
              if (!canUpgrade(1) || virgins < 2 || priests >= 3)
                break;
              upgrade(1);

              if (Game.debugAI)
                trace("!!! " + name + " upgrade adept, priests: " + priests);
            }
          return;
        }
    }


// lower investigator's willpower
  function aiLowerWillpower()
    {
      // no need to kill him yet
      if (!hasInvestigator || //(awareness < 5 && !isRitual) ||
          investigator.isHidden ||
          adepts == 0)
        return;

      for (i in 0...Game.numPowers)
        {
          lowerWillpower(i);
          lowerWillpower(i);
        }
    }


// try to lower awareness with virgins
  function aiLowerAwarenessHard()
    {
      if (awareness == 0 || adepts == 0)
        return;

      var prevAwareness = awareness;

      // spend all adepts we have
      while (virgins > 0 && adeptsUsed < adepts && awareness >= 0)
        {
          convert(3, 0);
          lowerAwareness(0);
        }

      if (Game.debugAI && awareness != prevAwareness)
        trace(name + " virgin awareness " + prevAwareness + "% -> " + awareness + "%");
    }


// try to lower awareness (virgins are not used)
  function aiLowerAwareness()
    {
      if ((awareness < difficulty.maxAwareness && !hasInvestigator) ||
          (awareness < 5 && hasInvestigator) ||
          adepts == 0 || adeptsUsed >= adepts)
        return;

      var prevAwareness = awareness;

      // spend all we have
      for (i in 0...Game.numPowers)
        while (power[i] > 0 && adeptsUsed < adepts &&
               awareness >= difficulty.maxAwareness)
          lowerAwareness(i);

      if (Game.debugAI && awareness != prevAwareness)
        trace(name + " awareness " + prevAwareness + "% -> " + awareness + "%");
    }


// try to summon elder god
  public function aiSummon()
    {
      if (priests < 3 || virgins < 9 || getUpgradeChance(2) < 50 || isRitual)
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
