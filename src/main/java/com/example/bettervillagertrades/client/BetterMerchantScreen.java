package com.example.bettervillagertrades.client;

import com.example.bettervillagertrades.network.TradeMaxPayload;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayNetworking;
import net.minecraft.client.gui.DrawContext;
import net.minecraft.client.gui.screen.ingame.HandledScreen;
import net.minecraft.entity.player.PlayerInventory;
import net.minecraft.item.ItemStack;
import net.minecraft.screen.MerchantScreenHandler;
import net.minecraft.text.Text;
import net.minecraft.util.Identifier;
import net.minecraft.util.math.MathHelper;
import net.minecraft.village.TradeOffer;
import net.minecraft.village.TradeOfferList;

public class BetterMerchantScreen extends HandledScreen<MerchantScreenHandler> {

    private static final Identifier TEXTURE = Identifier.ofVanilla("textures/gui/container/villager2.png");
    private float scrollAmount = 0.0f;
    private boolean isScrolling = false;

    // GUI metrics
    private final int listX = 5;
    private final int listY = 16;
    private final int listWidth = 110; // width of the list area
    private final int listHeight = 140; // height of the list area
    private final int itemHeight = 24;

    public BetterMerchantScreen(MerchantScreenHandler handler, PlayerInventory inventory, Text title) {
        super(handler, inventory, title);
        this.backgroundWidth = 276;
        this.backgroundHeight = 166;
    }

    @Override
    protected void init() {
        super.init();
        this.titleX = (this.backgroundWidth - this.textRenderer.getWidth(this.title)) / 2;
        this.titleY = 6;
    }

    @Override
    public void render(DrawContext context, int mouseX, int mouseY, float delta) {
        this.renderBackground(context, mouseX, mouseY, delta);
        super.render(context, mouseX, mouseY, delta);
        this.drawMouseoverTooltip(context, mouseX, mouseY);

        TradeOfferList trades = this.handler.getRecipes();
        if (trades != null && !trades.isEmpty()) {
            this.renderTradeList(context, mouseX, mouseY, trades);
        }
    }

    @Override
    protected void drawBackground(DrawContext context, float delta, int mouseX, int mouseY) {
        int i = (this.width - this.backgroundWidth) / 2;
        int j = (this.height - this.backgroundHeight) / 2;
        context.drawTexture(TEXTURE, i, j, 0, 0, this.backgroundWidth, this.backgroundHeight);
    }

    private void renderTradeList(DrawContext context, int mouseX, int mouseY, TradeOfferList trades) {
        int i = (this.width - this.backgroundWidth) / 2;
        int j = (this.height - this.backgroundHeight) / 2;

        int startX = i + listX;
        int startY = j + listY;

        int totalHeight = trades.size() * itemHeight;
        int maxScroll = Math.max(0, totalHeight - listHeight);
        int currentScrollOffset = (int) (this.scrollAmount * maxScroll);

        context.enableScissor(startX, startY, startX + listWidth, startY + listHeight);

        for (int index = 0; index < trades.size(); index++) {
            TradeOffer trade = trades.get(index);
            int yPos = startY + (index * itemHeight) - currentScrollOffset;

            // Only render items within the visible area
            if (yPos + itemHeight > startY && yPos < startY + listHeight) {
                renderTradeItem(context, trade, startX, yPos, mouseX, mouseY, index);
            }
        }

        context.disableScissor();

        // Render scrollbar
        if (maxScroll > 0) {
            int scrollbarX = startX + listWidth + 2;
            int scrollbarY = startY + (int) (this.scrollAmount * (listHeight - 15));
            context.fill(scrollbarX, startY, scrollbarX + 6, startY + listHeight, 0xFF555555); // background
            context.fill(scrollbarX, scrollbarY, scrollbarX + 6, scrollbarY + 15, 0xFFCCCCCC); // handle
        }
    }

    private void renderTradeItem(DrawContext context, TradeOffer trade, int x, int y, int mouseX, int mouseY, int index) {
        // Draw item background
        boolean isHovered = mouseX >= x && mouseX <= x + listWidth && mouseY >= y && mouseY <= y + itemHeight;
        int bgColor = isHovered ? 0xFFDDDDDD : 0xFFFFFFFF;
        context.fill(x, y, x + listWidth, y + itemHeight, bgColor);

        // Draw items
        ItemStack input1 = trade.getDisplayedFirstBuyItem();
        ItemStack input2 = trade.getDisplayedSecondBuyItem();
        ItemStack output = trade.getSellItem();

        context.drawItem(input1, x + 2, y + 4);
        context.drawItemInSlot(this.textRenderer, input1, x + 2, y + 4);

        if (!input2.isEmpty()) {
            context.drawItem(input2, x + 22, y + 4);
            context.drawItemInSlot(this.textRenderer, input2, x + 22, y + 4);
        }

        context.drawItem(output, x + 50, y + 4);
        context.drawItemInSlot(this.textRenderer, output, x + 50, y + 4);

        // Draw price/discount logic
        if (trade.getSpecialPrice() < 0) {
             context.drawText(this.textRenderer, String.valueOf(trade.getOriginalFirstBuyItem().getCount()), x + 2, y + 14, 0xFF0000, false);
             context.drawText(this.textRenderer, String.valueOf(trade.getDisplayedFirstBuyItem().getCount()), x + 10, y + 14, 0x00FF00, false);
        }

        // Draw visual cues for disabled trades
        if (trade.isDisabled()) {
            context.fill(x, y, x + listWidth, y + itemHeight, 0x88AAAAAA); // Grey out
            context.drawText(this.textRenderer, "LOCKED", x + listWidth - 45, y + 8, 0xFF0000, false);
        }

        // Detailed enchant tooltips for books without hovering
        if (output.isOf(net.minecraft.item.Items.ENCHANTED_BOOK)) {
            net.minecraft.component.type.ItemEnchantmentsComponent enchantments = output.getOrDefault(net.minecraft.component.DataComponentTypes.STORED_ENCHANTMENTS, net.minecraft.component.type.ItemEnchantmentsComponent.DEFAULT);
            if (!enchantments.isEmpty()) {
                var firstEnchant = enchantments.getEnchantmentEntries().iterator().next();
                Text enchantText = net.minecraft.enchantment.Enchantment.getName(firstEnchant.getKey(), firstEnchant.getIntValue());

                context.getMatrices().push();
                context.getMatrices().scale(0.7f, 0.7f, 0.7f);
                context.drawText(this.textRenderer, enchantText, (int)((x + 70) / 0.7f), (int)((y + 8) / 0.7f), 0xFFFF55, false);
                context.getMatrices().pop();
            }
        }
    }

    @Override
    public boolean mouseClicked(double mouseX, double mouseY, int button) {
        int i = (this.width - this.backgroundWidth) / 2;
        int j = (this.height - this.backgroundHeight) / 2;
        int startX = i + listX;
        int startY = j + listY;

        if (button == 0) {
            TradeOfferList trades = this.handler.getRecipes();
            if (trades != null && mouseX >= startX && mouseX <= startX + listWidth && mouseY >= startY && mouseY <= startY + listHeight) {
                int totalHeight = trades.size() * itemHeight;
                int maxScroll = Math.max(0, totalHeight - listHeight);
                int currentScrollOffset = (int) (this.scrollAmount * maxScroll);

                int clickY = (int) (mouseY - startY + currentScrollOffset);
                int index = clickY / itemHeight;

                if (index >= 0 && index < trades.size()) {
                    if (hasShiftDown()) {
                        ClientPlayNetworking.send(new TradeMaxPayload(index));
                    } else {
                        // Standard select logic
                        this.handler.setRecipeIndex(index);
                        this.client.getNetworkHandler().sendPacket(new net.minecraft.network.packet.c2s.play.SelectMerchantTradeC2SPacket(index));
                    }
                    return true;
                }
            }
        }
        return super.mouseClicked(mouseX, mouseY, button);
    }

    @Override
    public boolean mouseScrolled(double mouseX, double mouseY, double horizontalAmount, double verticalAmount) {
        TradeOfferList trades = this.handler.getRecipes();
        if (trades != null) {
            int totalHeight = trades.size() * itemHeight;
            int maxScroll = Math.max(0, totalHeight - listHeight);

            if (maxScroll > 0) {
                float scrollStep = 10.0f / maxScroll;
                this.scrollAmount = MathHelper.clamp(this.scrollAmount - (float) verticalAmount * scrollStep, 0.0f, 1.0f);
                return true;
            }
        }
        return super.mouseScrolled(mouseX, mouseY, horizontalAmount, verticalAmount);
    }
}
