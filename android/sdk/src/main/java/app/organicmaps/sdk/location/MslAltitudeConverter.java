package app.organicmaps.sdk.location;

import android.content.Context;
import android.location.Location;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import androidx.core.location.LocationCompat;
import java.io.IOException;
import java.io.InputStream;

/** Adds MSL metadata synchronously on the main thread, preserving the provider's ellipsoidal altitude. */
final class MslAltitudeConverter
{
  @Nullable
  private static Geoid sGeoid;

  private MslAltitudeConverter() {}

  @UiThread
  static void addMslAltitude(@NonNull Context context, @NonNull Location location)
  {
    if (LocationCompat.hasMslAltitude(location) && Double.isFinite(LocationCompat.getMslAltitudeMeters(location)))
      return;

    if (!location.hasAltitude() || !Double.isFinite(location.getAltitude())
        || !Geoid.isValidCoordinates(location.getLatitude(), location.getLongitude()))
      return;

    if (sGeoid == null)
    {
      try (InputStream input = context.getAssets().open(GeoidData.ASSET_PATH))
      {
        sGeoid = new Geoid(input);
      }
      catch (IOException e)
      {
        throw new IllegalStateException("Cannot load bundled geoid model", e);
      }
    }
    double geoidHeight = sGeoid.getHeight(location.getLatitude(), location.getLongitude());
    LocationCompat.setMslAltitudeMeters(location, location.getAltitude() - geoidHeight);
    LocationCompat.removeMslAltitudeAccuracy(location);
    if (LocationCompat.hasVerticalAccuracy(location))
    {
      float accuracy = LocationCompat.getVerticalAccuracyMeters(location);
      if (Float.isFinite(accuracy) && accuracy >= 0)
        LocationCompat.setMslAltitudeAccuracyMeters(location, (float) Math.hypot(accuracy, GeoidData.RMSE_METERS));
    }
  }
}
