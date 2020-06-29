-- Traitor radar rendering

local render = render
local surface = surface
local string = string
local player = player
local math = math

RADAR = {}
RADAR.targets = {}
RADAR.enable = false
RADAR.duration = 1
RADAR.endtime = 0
RADAR.bombs = {}
RADAR.bombs_count = 0
RADAR.repeating = true
RADAR.samples = {}
RADAR.samples_count = 0

function RADAR:EndScan()
   self.enable = false
   self.endtime = CurTime()
end

function RADAR:Clear()
   self:EndScan()
   self.bombs = {}
   self.samples = {}

   self.bombs_count = 0
   self.samples_count = 0
end

function RADAR:Timeout()
   --self:EndScan()

   if self.repeating and LocalPlayer() and LocalPlayer():Team() == TEAM_MONSTER or LocalPlayer():Team() == TEAM_SPECTATOR then
      RunConsoleCommand("predator_radar_scan")
   end
end

-- cache stuff we'll be drawing
function RADAR.CacheEnts()
end

local function DrawTarget(tgt, size, offset, no_shrink)
   local scrpos = tgt.pos:ToScreen() -- sweet
   local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size/2 or size

   scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
   scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
   
   if IsOffScreen(scrpos) then return end

   surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

   -- Drawing full size?
   if sz == size then
      local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos))
      local w, h = surface.GetTextSize(text)

      -- Show range to target
      surface.SetTextPos(scrpos.x - w/2, scrpos.y + (offset * sz) - h/2)
      surface.DrawText(text)

      if tgt.t then
         -- Show time
         text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
         w, h = surface.GetTextSize(text)

         surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
         surface.DrawText(text)
      elseif tgt.nick then
         -- Show nickname
         text = tgt.nick
         w, h = surface.GetTextSize(text)

         surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
         surface.DrawText(text)
      end
   end
end

local indicator   = surface.GetTextureID("effects/select_ring")
local sample_scan = surface.GetTextureID("vgui/ttt/sample_scan")

local FormatTime = util.SimpleTime

local near_cursor_dist = 180

function GM:HUDPaint()
    local client = LocalPlayer()
    if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTRadar" ) then
        RADAR:Draw(client)
    end
end

function RADAR:Draw(client)
   if not client then return end

   surface.SetFont("HudSelectionText")

   -- Samples
   if self.samples_count != 0 then
      surface.SetTexture(sample_scan)
      surface.SetTextColor(200, 50, 50, 255)
      surface.SetDrawColor(255, 255, 255, 240)

      for k, sample in pairs(self.samples) do
         DrawTarget(sample, 16, 0.5, true)
      end
   end

   -- Player radar
   if (not self.enable) then return end

   surface.SetTexture(indicator)

   local remaining = math.max(0, RADAR.endtime - CurTime())
   local alpha_base = 50 + 180 * (remaining / RADAR.duration)

   local mpos = Vector(ScrW() / 2, ScrH() / 2, 0)

   local role, alpha, scrpos, md
   for k, tgt in pairs(RADAR.targets) do
      alpha = alpha_base

      scrpos = tgt.pos:ToScreen()
      if not scrpos.visible then
         continue
      end
      md = mpos:Distance(Vector(scrpos.x, scrpos.y, 0))
      if md < near_cursor_dist then
         alpha = math.Clamp(alpha * (md / near_cursor_dist), 40, 230)
      end

      role = tgt.role or ROLE_INNOCENT
      if role == ROLE_TRAITOR then
         surface.SetDrawColor(255, 0, 0, alpha)
         surface.SetTextColor(255, 0, 0, alpha)

      elseif role == ROLE_DETECTIVE then
         surface.SetDrawColor(0, 0, 255, alpha)
         surface.SetTextColor(0, 0, 255, alpha)

      elseif role == 3 then -- decoys
         surface.SetDrawColor(150, 150, 150, alpha)
         surface.SetTextColor(150, 150, 150, alpha)

      else
         surface.SetDrawColor(200, 0, 0, alpha)
         surface.SetTextColor(200, 0, 0, alpha)
      end

      DrawTarget(tgt, 24, 0)
   end

   -- Time until next scan
   surface.SetFont("TabLarge")
   surface.SetTextColor(255, 0, 0, 230)

   -- local text = "Time until next scan: " .. FormatTime(remaining, "%02i:%02i")
   -- local w, h = surface.GetTextSize(text)

   -- surface.SetTextPos(36, ScrH() - 140 - h)
   -- surface.DrawText(text)
end

local function ReceiveRadarScan()
   local num_targets = net.ReadUInt(8)

   RADAR.targets = {}
   for i=1, num_targets do
      local r = net.ReadUInt(2)

      local pos = Vector()
      pos.x = net.ReadInt(32)
      pos.y = net.ReadInt(32)
      pos.z = net.ReadInt(32)

      table.insert(RADAR.targets, {role=r, pos=pos})
   end

   RADAR.enable = true
   RADAR.endtime = CurTime() + RADAR.duration

   timer.Create("radartimeout", 0.1, 1,
                function() RADAR:Timeout() end)
end
net.Receive("TTT_Radar", ReceiveRadarScan)
