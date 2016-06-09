part of slim_vendor_app_client.services;


class SlimViewChannelService {

  SlimView.Channel channel;
  SlimView.Config config;

}

@Injectable()
slimViewChannelServiceFactory() => new SlimViewChannelService();

const Provider slimViewChannelService = const Provider(SlimViewChannelService, useFactory: slimViewChannelServiceFactory);