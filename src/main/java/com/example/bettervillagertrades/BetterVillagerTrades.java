package com.example.bettervillagertrades;

import com.example.bettervillagertrades.network.TradeMaxPayload;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.networking.v1.PayloadTypeRegistry;
import net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking;
import net.minecraft.screen.MerchantScreenHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BetterVillagerTrades implements ModInitializer {
    public static final String MOD_ID = "bettervillagertrades";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("BetterVillagerTrades initialized!");

        PayloadTypeRegistry.playC2S().register(TradeMaxPayload.ID, TradeMaxPayload.CODEC);

        ServerPlayNetworking.registerGlobalReceiver(TradeMaxPayload.ID, (payload, context) -> {
            context.server().execute(() -> {
                if (context.player().currentScreenHandler instanceof MerchantScreenHandler merchantScreenHandler) {
                    int tradeIndex = payload.tradeIndex();
                    int maxAttempts = 64; // Fallback to prevent infinite loops

                    for (int i = 0; i < maxAttempts; i++) {
                        // Setting the recipe index refills the input slots from the player's inventory
                        // if they have the required items.
                        merchantScreenHandler.setRecipeIndex(tradeIndex);

                        // If the trade is no longer possible, the output slot will remain empty
                        if (merchantScreenHandler.getSlot(2).getStack().isEmpty()) {
                            break;
                        }

                        // Simulate a shift-click on the output slot (index 2)
                        merchantScreenHandler.onSlotClick(2, 0, net.minecraft.screen.slot.SlotActionType.QUICK_MOVE, context.player());
                    }
                }
            });
        });
    }
}
